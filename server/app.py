import simplejson as json
from flask import Flask
from flask import request

from interpreter import is_overdose
from response import Response

app = Flask(__name__)

heart_rates = []
response = Response()


@app.route('/startsession', methods=['GET', 'POST'])
def start_session():
    pass


@app.route('/location', methods=['GET', 'POST'])
def get_location():
    # get data
    raw = request.data
    parsed = json.loads(raw)
    latitude = parsed['latitude']
    longitude = parsed['longitude']
    # return
    response.location = str(latitude) + ", " + str(longitude)


@app.route('/hr', methods=['GET', 'POST'])
def get_hr():
    # get data
    raw = request.data
    parsed = json.loads(raw)
    heart_rate = parsed['heart_rate']
    date = parsed['date']
    time = parsed['time']
    # return
    heart_rates.append(heart_rate)
    if is_overdose(heart_rate):
        response.trigger_response()


@app.route('/contact-info', methods=['GET', 'POST'])
def get_contact_number():
    raw = request.data
    parsed = json.loads(raw)
    response.contact_number = parsed['contact_number']
    response.contact_name = parsed['contact_name']
    contact_preference = parsed['contact_preference']


@app.route('/overdose', methods=['GET', 'POST'])
def warn_overdose():
    pass


if __name__ == "__main__":
    app.run(host='0.0.0.0')

# TODO: migrate to session-based design, server should run continuously
# Session has its own HR list and Response object with location and contact info
# Start a new session each time app is opened, phone POSTs to '/startsession' with location
# '/contact-info' will update the session's number
# During session, continuously check HR at '/hr' and interpret result
# If response triggered, close session (but keep server running)
