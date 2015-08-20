import sensor
import time
from datetime import datetime
from firebase import firebase

if __name__ == '__main__':
    firebase = firebase.FirebaseApplication('https://temperature-sensor.firebaseio.com', None)

    def writer(temperature, humidity):
        measurement = {"temperature": temperature,
                       "humidity": humidity,
                       "date": time.time() * 1000}

        result = firebase.post('/measurements', measurement)
        print(result)

    sensor.read(writer)
