import sensor
from datetime import datetime
from firebase import firebase

if __name__ == '__main__':
    firebase = firebase.FirebaseApplication('https://temperature-sensor.firebaseio.com', None)

    def writer(temperature, humidity):
        measurement = {"temperature": temperature,
                       "humidity": humidity,
                       "date": datetime.utcnow()}

        result = firebase.post('/measurements', measurement)
        print(result)

    sensor.read(writer)
