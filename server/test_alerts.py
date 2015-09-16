from alerts import Alerts
from firebase import firebase
import pytest
import operator

# Change to a dummy database
dummy_database = 'alerts-test'

@pytest.fixture
def fb():
    fb = firebase.FirebaseApplication('https://temperature-sensor.firebaseio.com', None)
    return fb


def test_init(fb):
    # Delete everything
    fb.delete(dummy_database, None)

    alerts = Alerts(dummy_database)
    assert len(alerts.alerts) == 0


def test_previous_data(fb):
    email = "test@test"
    type = "temperature"
    bound = 80
    direction = "gt"

    # Add previous data
    fb.post(dummy_database,
            {"email": email, "type": type, "bound": bound, "direction": direction})

    alerts = Alerts(dummy_database)

    print(alerts.alerts)

    assert alerts.alerts is not None
    assert len(alerts.alerts) == 1
    assert alerts.alerts.ix[0].email == email
    assert alerts.alerts.ix[0].type == type
    assert alerts.alerts.ix[0].bound == bound
    assert alerts.alerts.ix[0].direction == operator.gt if direction == 'gt' else operator.lt


def test_add(fb):
    email = "test@test"
    type = "temperature"
    bound = 80
    direction = "gt"

    # Delete everything
    fb.delete(dummy_database, None)

    # Create new alerts
    alerts = Alerts(dummy_database)
    assert len(alerts.alerts) == 0

    # Add one alert
    alerts.add_alert(email, type, bound, direction)

    assert len(alerts.alerts) == 1
    assert alerts.alerts.ix[0].email == email
    assert alerts.alerts.ix[0].type == type
    assert alerts.alerts.ix[0].bound == bound
    assert alerts.alerts.ix[0].direction == operator.gt if direction == 'gt' else operator.lt

    # Try adding again
    alerts.add_alert(email, type, bound, direction)

    # Nothing should have changed
    assert len(alerts.alerts) == 1
    assert alerts.alerts.ix[0].email == email
    assert alerts.alerts.ix[0].type == type
    assert alerts.alerts.ix[0].bound == bound
    assert alerts.alerts.ix[0].direction == operator.gt if direction == 'gt' else operator.lt


def test_delete(fb):
    email = "test@test"
    type = "temperature"
    bound = 80
    direction = "gt"

    # Delete everything
    fb.delete(dummy_database, None)

    # Add previous data
    fb.post(dummy_database,
            {"email": email, "type": type, "bound": bound, "direction": direction})

    alerts = Alerts(dummy_database)

    # Delete alert
    alerts.delete_alert(email, type, bound, direction)
    assert len(alerts.alerts) == 0

    # Try deleting alert again
    alerts.delete_alert(email, type, bound, direction)
    assert len(alerts.alerts) == 0


def test_add_and_delete(fb):
    email = "test@test"
    type = "temperature"
    bound = 80
    direction = "gt"

    # Delete everything
    fb.delete(dummy_database, None)

    alerts = Alerts(dummy_database)
    assert len(alerts.alerts) == 0

    alerts.add_alert(email, type, bound, direction)
    assert len(alerts.alerts) == 1
    assert alerts.alerts.ix[0].email == email
    assert alerts.alerts.ix[0].type == type
    assert alerts.alerts.ix[0].bound == bound
    assert alerts.alerts.ix[0].direction == operator.gt if direction == 'gt' else operator.lt

    alerts.delete_alert(email, type, bound, direction)
    assert len(alerts.alerts) == 0


def test_clear(fb):
    email = "test@test"
    type = "temperature"
    bound = 80
    direction = "gt"

    # Delete everything
    fb.delete(dummy_database, None)

    alerts = Alerts(dummy_database)
    assert len(alerts.alerts) == 0

    alerts.add_alert(email, type, bound, direction)
    assert len(alerts.alerts) == 1
    assert alerts.alerts.ix[0].email == email
    assert alerts.alerts.ix[0].type == type
    assert alerts.alerts.ix[0].bound == bound
    assert alerts.alerts.ix[0].direction == operator.gt if direction == 'gt' else operator.lt

    alerts.clear_alerts()
    assert len(alerts.alerts) == 0
