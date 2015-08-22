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

def get_data():
    fb = firebase.FirebaseApplication('https://temperature-sensor.firebaseio.com', None)
    last_get_data = int(time.time() * 1000)

    print("getting new data")
    results = fb.get('', 'measurements', params={'orderBy': '"date"'})
    results = list(results.values())

    # Set up data frame
    df = pd.DataFrame(results)
    df['date'] = df['date'].map(parse_time)
    df = df.set_index('date')
    df = df.sort()

    # Convert C to F
    df['temperature'] = df['temperature'] * 9/5 + 32

    def _get_more_data():
        nonlocal df
        nonlocal last_get_data

        results = fb.get('', 'measurements', params={'orderBy': '"date"', 'startAt': last_get_data})
        results = list(results.values())

        print(results)

        # Add to data frame

        last_get_data = int(time.time() * 1000)
        return df


    return df, _get_more_data





if __name__ == '__main__':
    app.run(debug=True)
