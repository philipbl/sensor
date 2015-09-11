from firebase import firebase
from itertools import combinations
import numpy as np
import pandas as pd
import threading

class Alerts(object):
    def __init__(self):
        super(Alerts, self).__init__()
        self.fb = firebase.FirebaseApplication('https://temperature-sensor.firebaseio.com', None)
        self.alerts = self._get_past_alerts()

    def _get_latest_data(self):
        # TODO: Limit to one entry
        # results = self.fb.get('', 'measurements', params={'orderBy': '"date"'})
        return 90, 40

    def _get_past_alerts(self):
        # TODO: Build structure from firebase
        results = self.fb.get('', 'alerts')

        return pd.DataFrame(columns=['type', 'bound', 'direction', 'email'])

    def _check_for_triggered_alerts(self):
        temperature, humidity = self._get_latest_data()

        df = self.alerts
        active_alerts = []
        for type in ['temperature', 'humidity']:

            active_alerts.append(df[(df.type == type) &
                                    (df.direction == 'gt') &
                                    (temperature > df.bound)])

            active_alerts.append(df[(df.type == type) &
                                    (df.direction == 'lt') &
                                    (temperature < df.bound)])

        active_alerts = pd.concat(active_alerts)
        return active_alerts

    def _trigger_alerts(self, alerts):
        # TODO: Finish
        pass

    def run(self):
        alerts = self._check_for_triggered_alerts()
        self._trigger_alerts(alerts)

        threading.Timer(60, self.run).start()

    def add_alert(self, email, type, bound, direction):
        # TODO: Add to database

        s = pd.Series([type, bound, direction, email],
                      index=['type', 'bound', 'direction', 'email'])
        self.alerts = self.alerts.append(s, ignore_index=True)

    def delete_alert(self, email, type, bound, direction):
        # TODO: Remove from database

        df = self.alerts
        self.alerts = df[(df.type != type) |
                         (df.bound != bound) |
                         (df.direction != direction) |
                         (df.email != email)]


alerts = Alerts()
alerts.add_alert("philiplundrigan@gmail.com", 'temperature', 70, 'gt')
alerts.add_alert("philiplundrigan@gmail.com", 'temperature', 80, 'gt')
alerts.add_alert("philiplundrigan@gmail.com", 'temperature', 60, 'lt')
# print(alerts.alerts)
# alerts.delete_alert("philiplundrigan@gmail.com", 'temperature', 70, 'gt')
# alerts.delete_alert("philiplundrigan@gmail.com", 'temperature', 60, 'lt')
# print(alerts.alerts)
alerts.run()

