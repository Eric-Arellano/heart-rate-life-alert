import simplejson as json
from flask import Flask, current_app
from flask import request

from interpreter import is_simple_overdose, is_fake_kill
from response import Response

app = Flask(__name__)

response = Response()


@app.route('/location', methods=['GET', 'POST'])
def get_location():
    parsed = extract_json(request.form)
    latitude = parsed['latitude']
    longitude = parsed['longitude']
    response.location = str(latitude) + "," + str(longitude)
    return "Location received."


@app.route('/contact-info', methods=['GET', 'POST'])
def get_contact_number():
    parsed = extract_json(request.form)
    response.contact_number = "+1" + parsed['contact_number']
    response.contact_name = parsed['contact_name']
    response.contact_preference = parsed['contact_preference']
    response.cause = parsed['contact_cause']
    return 'Contact preferences received.'


@app.route('/start-monitoring', methods=['GET', 'POST'])
def start_monitoring():
    response.notify_contact_of_start()
    return "Contact notified."


@app.route('/master-kill', methods=['GET', 'POST'])
def master_kill():
    response.trigger_response()
    return "Master kill."


@app.route('/twiml')
def get_twiml():
    return current_app.send_static_file('phone-script.xml')


@app.route('/stop-app', methods=['GET', 'POST'])
def stop_app():
    return "Stop app."


def extract_json(request_form):
    for jsonString in request_form:
        js = jsonString
        print jsonString
    return json.loads(js)


if __name__ == "__main__":
    app.run(host='0.0.0.0')
