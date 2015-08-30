import sensor
import time
from datetime import datetime
from firebase import firebase

firebase_name = 'https://temperature-sensor.firebaseio.com'

def start_writer():
    fb = firebase.FirebaseApplication(firebase_name, None)

    def writer(temperature, humidity):
        nonlocal fb

        try:
            measurement = {"temperature": round(temperature, 2),
                           "humidity": round(humidity, 2),
                           "date": int(time.time() * 1000)}

            result = fb.post('/measurements', measurement)
            print(result)
        except Exception as e:
            print(e)
            print("Trying to reconnect...")
            fb = firebase.FirebaseApplication(firebase_name, None)

    return writer

if __name__ == '__main__':
    sensor.read(start_writer())
