from flask import Flask, jsonify, request
from flask.ext.cors import CORS
from datetime import datetime
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



app = Flask(__name__)
CORS(app)
data, get_more_data = get_data()

@app.route("/sensor/status")
def status():
    data = get_more_data()
    response = {"last_reading": data.ix[-1].name}

    return jsonify(**response)


@app.route("/sensor/summary")
def summary():
    data = get_more_data()
    # TODO: Get data for only a certain amount of time
    response = {"mean_temp": data['temperature'].mean(),
                "min_temp": data['temperature'].min(),
                "max_temp": data['temperature'].max(),
                "mean_humidity": data['humidity'].mean(),
                "min_humidity": data['humidity'].min(),
                "max_humidity": data['humidity'].max()}

    return jsonify(**response)


@app.route("/sensor/stats/<time_scale>")
def average(time_scale):
    """
    Returns statistics (mean, median, 25 percentile, and 75 percentile)
    about the given time scale. Time scale can be year, month, day, hour,
    day of month, day of week and hour of day. Start and end parameters
    can be provided to cut down on the data.
    """

    # Average day and night?
    data = get_more_data()

    start = request.args.get('start')
    end = request.args.get('end')


@app.route("/sensor/readings/<time_scale>")
def readings(time_scale):
    data = get_more_data()

    start = request.args.get('start')
    end = request.args.get('end')

    # if time_scale == 'minute' or time_scale == 'min':
    #     response = {"temperature": data[start:end]['temperature'],
    #                 "humidity": data[start:end]['humidity']}

    return data['temperature'].to_json()

if __name__ == '__main__':
    app.run(debug=True)
