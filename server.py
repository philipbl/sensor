from flask import Flask
from datetime import datetime
from firebase import firebase

# firebase = firebase.FirebaseApplication('https://temperature-sensor.firebaseio.com', None)

app = Flask(__name__)

if __name__ == '__main__':
    app.run(debug=True)
