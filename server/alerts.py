from firebase import firebase
from itertools import combinations
import numpy as np
import pandas as pd
import threading
import operator

class Alerts(object):
    def __init__(self, database="alerts"):
        super(Alerts, self).__init__()
        self.fb = firebase.FirebaseApplication('https://temperature-sensor.firebaseio.com', None)
        self.database = database
        self.alerts = self._get_stored_alerts()

    def _get_latest_data(self):
        results = self.fb.get('', 'measurements', params={'orderBy': '"date"', 'limitToLast': 1})
        return list(results.values())[0]

    def _get_past_alerts(self):
        results = self.fb.get('', self.database)

        data = []
        for key, value in results.items():
            value['name'] = key
            value['active'] = False
            value['direction'] = operator.gt if value['direction'] == 'gt' else operator.lt
            data.append(value)

        df = pd.DataFrame(data)
        df = df.set_index('name')
        return df

    def _trigger_alert(self, trigger, current):
        print("Send email to {} saying:".format(trigger.email))
        print("{type} has gone {direction} {bound} ({current}).".format(type=trigger.type,
                                                                        direction="above" if trigger.direction == operator.gt else "below",
                                                                        bound=trigger.bound,
                                                                        current=current[trigger.type]))
        print()

    def _trigger_alerts(self):
        data = self._get_latest_data()
        df = self.alerts

        for i in range(len(df)):
            series = df.ix[i]

            if series.direction(data[series.type], series.bound) and \
               not series.active:
               df.loc[i, 'active'] = True
               self._trigger_alert(series, data)
            else:
                df.loc[i, 'active'] = False

    def run(self):
        alerts = self._trigger_alerts()
        # threading.Timer(60, self.run).start()

    def add_alert(self, email, type, bound, direction):
        # Store alert in database
        result = self.fb.post(self.database,
                             {"email": email, "type": type, "bound": bound, "direction": direction})

        # Keep track of alert locally
        direction = operator.gt if direction == 'gt' else operator.lt
        s = pd.Series([type, bound, direction, email, False],
                      index=['type', 'bound', 'direction', 'email', 'active'],
                      name=result['name'])
        self.alerts = self.alerts.append(s)

    def delete_alert(self, email, type, bound, direction):
        # TODO: Remove from database

        df = self.alerts
        self.alerts = df[(df.type != type) |
                         (df.bound != bound) |
                         (df.direction != direction) |
                         (df.email != email)]


alerts = Alerts()
# alerts.add_alert("philiplundrigan@gmail.com", 'temperature', 70, 'gt')
alerts.add_alert("philiplundrigan@gmail.com", 'temperature', 80, 'gt')
# alerts.add_alert("philiplundrigan@gmail.com", 'temperature', 60, 'lt')
print(alerts.alerts)
# alerts.delete_alert("philiplundrigan@gmail.com", 'temperature', 70, 'gt')
# alerts.delete_alert("philiplundrigan@gmail.com", 'temperature', 60, 'lt')
# print(alerts.alerts)
# alerts.run()

