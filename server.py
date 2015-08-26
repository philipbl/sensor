from flask import Flask, jsonify, request
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
    # TODO: Don't make a request if it has been called less than 60 seconds
    fb = firebase.FirebaseApplication('https://temperature-sensor.firebaseio.com', None)
    last_get_data = int(time.time() * 1000)

    results = fb.get('', 'measurements', params={'orderBy': '"date"'})
    results = list(results.values())
    df = format_data(results)

    def _get_more_data():
        nonlocal df
        nonlocal last_get_data

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

@app.route("/sensor/status")
def status():
    data = get_more_data()
    response = {"last_reading": data.ix[-1].name.value // 10**6}

    return jsonify(**response)


@app.route("/sensor/summary")
def summary():
    data = get_more_data()
    # TODO: Get data for only a certain amount of time
    response = {"temperature":
                    {
                        "mean": data['temperature'].mean(),
                        "min": data['temperature'].min(),
                        "max": data['temperature'].max()
                    },
                "humidity":
                    {
                        "mean": data['humidity'].mean(),
                        "min": data['humidity'].min(),
                        "max": data['humidity'].max()
                    }
                }
    return jsonify(**response)


@app.route("/sensor/stats/<time_scale>")
def stats(time_scale):
    data = get_more_data()

    # TODO: Handle all time?
    interval = request.args.get('interval', 1)
    duration = int(request.args.get('duration'))

    end = datetime.now()
    print("Requesting time_scale: {}, interval: {}".format(time_scale, interval))
    # Resample with how='describe'

    if time_scale == "minute":
        start = end - timedelta(minutes=duration)
        response = data.resample('{}T'.format(interval)).dropna()[start:end]

    elif time_scale == "hour":
        start = end - timedelta(hours=duration)
        response = data.resample('{}H'.format(interval)).dropna()[start:end]

    elif time_scale == "day":
        start = end - timedelta(days=duration)
        response = data.resample('{}D'.format(interval)).dropna()[start:end]

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
