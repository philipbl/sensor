import sensor
from flask import Flask
# from flask_restful import Resource, Api
# from pymongo import MongoClient
from datetime import datetime
from firebase import firebase

# client = MongoClient()
# db = client.measurements_db
# measurements = db.measurements_collection

firebase = firebase.FirebaseApplication('https://temperature-sensor.firebaseio.com', None)

app = Flask(__name__)
# api = Api(app)

def writer(temperature, humidity):
    measurement = {"temperature": temperature,
                   "humidity": humidity,
                   "date": datetime.utcnow()}

    result = firebase.post('/measurements', measurement)
    print(result)

    # measurements.insert_one(measurement)


if __name__ == '__main__':
    sensor.read(writer)
    app.run(debug=True)
