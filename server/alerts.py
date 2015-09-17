from firebase import firebase
from itertools import combinations
import numpy as np
import pandas as pd
import threading
import operator
import logging

logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.INFO)

class Alerts(object):
    def __init__(self, database="alerts"):
        super(Alerts, self).__init__()
        self.fb = firebase.FirebaseApplication('https://temperature-sensor.firebaseio.com', None)
        self.database = database
        self.alerts = self._get_stored_alerts()

    def _get_latest_data(self):
        results = self.fb.get('', 'measurements', params={'orderBy': '"date"', 'limitToLast': 1})
        data = list(results.values())[0]
        data['temperature'] = data['temperature'] * 9/5 + 32

        logging.info("Getting lastest data: %s", data)
        return data

    def _get_stored_alerts(self):
        logging.info("Getting stored alerts")

        results = self.fb.get('', self.database)

        if results is None:
            logging.info("There are no stored alerts")
            return pd.DataFrame([], columns=['type', 'bound', 'direction', 'id', 'active'])

        data = []
        for key, value in results.items():
            value['name'] = key
            value['active'] = False
            value['direction'] = operator.gt if value['direction'] == 'gt' else operator.lt
            data.append(value)

        df = pd.DataFrame(data)
        df = df.set_index('name')

        logging.info("Stored alerts:\n %s", df)
        return df

    def _trigger_alert(self, trigger, current):
        logging.info("Triggering an alert!")
        print("Send email to {} saying:".format(trigger.id))
        print("{type} has gone {direction} {bound} ({current}).".format(type=trigger.type,
                                                                        direction="above" if trigger.direction == operator.gt else "below",
                                                                        bound=trigger.bound,
                                                                        current=current[trigger.type]))
        print()

    def _trigger_alerts(self):
        logging.info("Checking if any alerts triggered")
        data = self._get_latest_data()
        df = self.alerts

        for i in range(len(self.alerts)):
            series = self.alerts.ix[i]

            if series.direction(data[series.type], series.bound):
                logging.info("Condition has been met!")

                if series.active:
                    logging.info("Not triggering alert because it was already triggered")
                else:
                    df.loc[i, 'active'] = True
                    self._trigger_alert(series, data)
            else:
                logging.info("Turning off active")
                df.loc[i, 'active'] = False

    def _find_alert(self, id, type, bound, direction):
        if self.alerts is None:
            return []

        df = self.alerts
        direction = operator.gt if direction == 'gt' else operator.lt

        alert = df[(df.type == type) &
                   (df.bound == bound) &
                   (df.direction == direction) &
                   (df.id == id)]

        return alert

    def run(self):
        alerts = self._trigger_alerts()
        threading.Timer(60, self.run).start()

    def add_alert(self, id, type, bound, direction):
        logging.info("Adding new alert: %s %s %s %s", id, type, bound, direction)

        bound = float(bound)
        alert = self._find_alert(id, type, bound, direction)
        if len(alert) > 0:
            logging.info("Alert is already contained in database")
            return

        # Store alert in database
        result = self.fb.post(self.database,
                             {"id": id, "type": type, "bound": bound, "direction": direction})

        # Keep track of alert locally
        direction = operator.gt if direction == 'gt' else operator.lt
        s = pd.Series([type, bound, direction, id, False],
                      index=['type', 'bound', 'direction', 'id', 'active'],
                      name=result['name'])
        self.alerts = self.alerts.append(s)

        logging.info("New alerts:\n %s", self.alerts)

    def delete_alert(self, id, type, bound, direction):
        logging.info("Deleting alert: %s %s %s %s", id, type, bound, direction)

        bound = float(bound)
        alert = self._find_alert(id, type, bound, direction)
        if len(alert) == 0:
            logging.info("There is no alert to delete")
            return

        # Remove alert from database
        self.fb.delete(self.database, alert.index[0])

        # Remove alert locally
        self.alerts = self.alerts.drop([alert.index[0]])

        logging.info("New alerts:\n %s", self.alerts)

    def clear_alerts(self):
        # Clear database
        self.fb.delete(self.database, None)

        # Clear locally
        self.alerts = pd.DataFrame([], columns=['type', 'bound', 'direction', 'id', 'active'])
