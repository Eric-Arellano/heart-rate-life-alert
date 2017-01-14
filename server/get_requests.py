from flask import Flask
from flask import request
from simplejson import json

app = Flask(__name__)


@app.route('/startsession', methods=['GET', 'POST'])
def start_session():
    pass


@app.route('/location', methods=['GET', 'POST'])
def get_location():
    raw = request.data
    parsed = json.loads(raw)
    latitude = parsed['latitude']
    longitude = parsed['longitude']
    return str(latitude) + ", " + str(longitude)


@app.route('/hr', methods=['GET', 'POST'])
def get_hr():
    raw = request.data
    parsed = json.loads(raw)
    heart_rate = parsed['heart_rate']
    return heart_rate
    # TODO: for now, ignoring date/time value


@app.route('/contact-number', methods=['GET', 'POST'])
def get_contact_number():
    raw = request.data
    parsed = json.loads(raw)
    contact_number = parsed['contact_number']
    return contact_number


@app.route('/overdose', methods=['GET', 'POST'])
def warn_overdose():
    pass
