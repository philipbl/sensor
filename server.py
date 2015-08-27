from flask import Flask, jsonify, request, render_template
from flask.ext.cors import CORS
from datetime import datetime, timedelta
from firebase import firebase
import numpy as np
import pandas as pd
import dateutil.parser
import time


def parse_time(time):
    if type(time) is str:
        return dateutil.parser.parse(time)
    else:
        return datetime.fromtimestamp(time / 1000)


def format_data(results):
    # Set up data frame
    df = pd.DataFrame(results)
    df['date'] = df['date'].map(parse_time)
    df = df.set_index('date')
    df = df.sort()

    # Convert C to F
    df['temperature'] = df['temperature'] * 9/5 + 32

    return df


def get_data():
    fb = firebase.FirebaseApplication('https://temperature-sensor.firebaseio.com', None)
    last_get_data = int(time.time() * 1000)
    last_minute = datetime.now().minute

    results = fb.get('', 'measurements', params={'orderBy': '"date"'})
    results = list(results.values())
    df = format_data(results)

    def _get_more_data():
        nonlocal df
        nonlocal last_get_data
        nonlocal last_minute

        current_minute = datetime.now().minute

        # Only check for new data if there is a new minute
        if current_minute == last_minute:
            return df
        else:
            last_minute = current_minute

        results = fb.get('', 'measurements', params={'orderBy': '"date"', 'startAt': last_get_data})
        results = list(results.values())

        if len(results) == 0:
            return df
        else:
            new_df = format_data(results)
            df = df.append(new_df)

            last_get_data = int(time.time() * 1000)
            return df

    return df, _get_more_data


def format_response(data, x_func, y_func):
    new_data = {}
    for c in data:
        new_data[c] = [{"x": x_func(index), "y": y_func(value)}
                       for index, value in data[c].iteritems()]

    return new_data


app = Flask(__name__)
CORS(app)
data, get_more_data = get_data()

@app.route("/")
def main():
    return render_template("index.html")

@app.route("/sensor/status")
def status():
    data = get_more_data()
    response = {"last_reading": data.ix[-1].name.value // 10**6}

    return jsonify(**response)


@app.route("/sensor/summary")
def summary():
    data = get_more_data()

    duration = int(request.args.get('duration'))
    end = datetime.now()
    start = end - timedelta(minutes=duration)

    response = {}
    for c in data:
        current = data[-2:-1]
        current.index = ["current"]
        response[c] = dict(data[start:end].describe().append(current)[c])

    return jsonify(**response)


@app.route("/sensor/stats/<time_scale>")
def stats(time_scale):
    data = get_more_data()
    time_str = {'minutes': 'T', 'hours': 'H', 'days': 'D'}

    interval = request.args.get('interval', 1)
    duration = int(request.args.get('duration', 0))

    end = datetime.now()
    start = end - timedelta(**{time_scale: duration})

    if start == end:
        start = None

    resample_str = '{}{}'.format(interval, time_str[time_scale])
    response = data.resample(resample_str).dropna()[start:end]

    # TODO: Return error if not a valid time scale

    return jsonify(**format_response(response,
                                     lambda x: x.value // 10**6,
                                     lambda y: y))


@app.route("/sensor/average/<time_scale>")
def average(time_scale):
    data = get_more_data()

    if time_scale == "day":
        response = data.groupby(lambda x: datetime(1900, 1, 1, x.hour)).mean()
        format_str = "%I:%M %p"

    elif time_scale == "week":
        response = data.groupby(lambda x: datetime(1900, 1, x.weekday() + 1)).mean()
        format_str = "%A"

    new_response = {"labels": [x.strftime(format_str) for x in response.index]}
    for c in response:
        new_response[c] = list(response[c])

    return jsonify(**new_response)


if __name__ == '__main__':
    app.run(debug=True)
