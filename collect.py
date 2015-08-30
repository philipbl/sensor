import sensor
import time
from datetime import datetime
from firebase import firebase

if __name__ == '__main__':
    firebase = firebase.FirebaseApplication('https://temperature-sensor.firebaseio.com', None)

    def writer(temperature, humidity):
        measurement = {"temperature": round(temperature, 2),
                       "humidity": round(humidity, 2),
                       "date": int(time.time() * 1000)}

        result = firebase.post('/measurements', measurement)
        print(result)

    sensor.read(writer)
