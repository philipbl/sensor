from flask import Flask
from datetime import datetime
from firebase import firebase
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import dateutil.parser

def parse_time(time):
    if type(time) is str:
        return dateutil.parser.parse(time)
    else:
        return time

def get_data():
    fb = firebase.FirebaseApplication('https://temperature-sensor.firebaseio.com', None)
    results = fb.get('/measurements', None)
    results = list(results.values())

    # Set up data frame
    df = pd.DataFrame(results)
    df['date'] = df['date'].map(parse_time)
    df = df.set_index('date')

    # Convert C to F
    df['temperature'] = df['temperature'] * 9/5 + 32

    return df


df = get_data()

print(df.describe())

# fig = plt.figure()
# ax = fig.add_subplot(111)

# ax.plot(df['temperature'])
# ax.plot(pd.ewma(df['temperature'], span=60))
# ax.plot(pd.rolling_mean(df['temperature'], window=60))

# ax.plot(time, temperature, '.')
# ax.plot(time, humidity, '.')

# ax.set_ylim(0)

# plt.show()

exit()

app = Flask(__name__)

if __name__ == '__main__':
    app.run(debug=True)
