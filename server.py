from flask import Flask
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
        new_df = format_data(results)
        df = df.append(new_df)

        last_get_data = int(time.time() * 1000)
        return df


    return df, _get_more_data


data, get_more_data = get_data()

print(data)

time.sleep(130)

data = get_more_data()
print(data)


if __name__ == '__main__':
    app.run(debug=True)
