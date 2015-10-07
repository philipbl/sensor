from firebase import firebase
from itertools import combinations
import numpy as np
import pandas as pd
import threading
import operator
import logging

logger = logging.getLogger(__name__)

class Alerts(object):
    def __init__(self, triggered_func, database="alerts"):
        super(Alerts, self).__init__()

        if not hasattr(triggered_func, '__call__'):
            raise Exception("triggered_func must be callable")

        self.fb = firebase.FirebaseApplication('https://temperature-sensor.firebaseio.com', None)
        self.triggered_func = triggered_func
        self.database = database
        self.alerts = self._get_stored_alerts()

    def _get_latest_data(self):
        try:
            results = self.fb.get('', 'measurements', params={'orderBy': '"date"', 'limitToLast': 1})
            data = list(results.values())[0]
            data['temperature'] = data['temperature'] * 9/5 + 32

            logger.info("Getting lastest data: %s", data)
            return data
        except:
            logger.error("An error occurred while getting the latest data from firebase")
            return None

    def _get_stored_alerts(self):
        logger.info("Getting stored alerts")

        results = self.fb.get('', self.database)

        if results is None:
            logger.info("There are no stored alerts")
            return pd.DataFrame([], columns=['type', 'bound', 'direction', 'id', 'active'])

        data = []
        for key, value in results.items():
            value['name'] = key
            value['active'] = False
            value['direction'] = operator.gt if value['direction'] == 'gt' else operator.lt
            data.append(value)

        df = pd.DataFrame(data)
        df = df.set_index('name')

        logger.info("Stored alerts:\n %s", df)
        return df

    def _trigger_alert(self, trigger, current):
        logger.info("Triggering an alert!")

        if self.triggered_func is None:
            logger.debug("triggered_func is None...")
            return

        self.triggered_func(trigger.id,
                            trigger.type,
                            trigger.bound,
                            'gt' if trigger.direction == operator.gt else 'lt',
                            current)

    def _trigger_alerts(self):
        logger.info("Checking if any alerts triggered")
        data = self._get_latest_data()
        df = self.alerts

        if data is None:
            # Didn't receive data, so just stop
            return

        for i in range(len(self.alerts)):
            series = self.alerts.ix[i]

            if series.direction(data[series.type], series.bound):
                logger.info("Condition has been met!")

                if series.active:
                    logger.info("Not triggering alert because it was already triggered")
                else:
                    self.alerts.loc[series.name, 'active'] = True
                    self._trigger_alert(series, data)
            elif series.active:
                self.alerts.loc[series.name, 'active'] = False

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

    def get_alerts(self):
        data = self.alerts.to_dict('records')

        for d in data:
            d['direction'] = 'gt' if d['direction'] == operator.gt else 'lt'

        return {'alerts': data}

    def add_alert(self, id, type, bound, direction):
        logger.info("Adding new alert: %s %s %s %s", id, type, bound, direction)

        bound = float(bound)
        alert = self._find_alert(id, type, bound, direction)
        if len(alert) > 0:
            logger.info("Alert is already contained in database")
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

        logger.info("New alerts:\n %s", self.alerts)

    def delete_alert(self, id, type, bound, direction):
        logger.info("Deleting alert: %s %s %s %s", id, type, bound, direction)

        bound = float(bound)
        alert = self._find_alert(id, type, bound, direction)
        if len(alert) == 0:
            logger.info("There is no alert to delete")
            return

        # Remove alert from database
        self.fb.delete(self.database, alert.index[0])

        # Remove alert locally
        self.alerts = self.alerts.drop([alert.index[0]])

        logger.info("New alerts:\n %s", self.alerts)

    def clear_alerts(self):
        logger.info("Clearing alerts")

        # Clear database
        self.fb.delete(self.database, None)

        # Clear locally
        self.alerts = pd.DataFrame([], columns=['type', 'bound', 'direction', 'id', 'active'])
