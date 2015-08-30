import sensor
import time
from datetime import datetime
from firebase import firebase

firebase_name = 'https://temperature-sensor.firebaseio.com'

if __name__ == '__main__':
    firebase = firebase.FirebaseApplication(firebase_name, None)

    def writer(temperature, humidity):
        try:
            measurement = {"temperature": round(temperature, 2),
                           "humidity": round(humidity, 2),
                           "date": int(time.time() * 1000)}

            result = firebase.post('/measurements', measurement)
            print(result)
        except Exception as e:
            print(e)
            print("Trying to reconnect...")
            firebase = firebase.FirebaseApplication(firebase_name, None)

    sensor.read(writer)
