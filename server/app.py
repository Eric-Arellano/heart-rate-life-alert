import simplejson as json
from flask import Flask
from flask import request

from interpreter import is_overdose, is_fake_kill
from response import Response

app = Flask(__name__)

heart_rates = []
response = Response()


@app.route('/dashboard', methods=['GET'])
def start_session():
    return ", ".join(heart_rates)


@app.route('/location', methods=['GET', 'POST'])
def get_location():
    parsed = extract_json(request.form)
    latitude = parsed['latitude']
    longitude = parsed['longitude']
    response.location = str(latitude) + "," + str(longitude)
    return "Location received."


@app.route('/hr', methods=['GET', 'POST'])
def get_hr():
    parsed = extract_json(request.form)
    heart_rate = parsed['heart_rate']
    # date = parsed['date']
    # time = parsed['time']
    heart_rates.append(heart_rate)
    if is_overdose(heart_rate):
        response.trigger_response()
        return "Overdose."
    return "HR okay."


@app.route('/contact-info', methods=['GET', 'POST'])
def get_contact_number():
    parsed = extract_json(request.form)
    response.contact_number = "+1" + parsed['contact_number']
    response.contact_name = parsed['contact_name']
    response.contact_preference = parsed['contact_preference']
    response.cause = parsed['contact_cause']
    return 'Contact preferences received.'


@app.route('/fake-kill', methods=['GET', 'POST'])
def fake_kill():
    parsed = extract_json(request.form)
    heart_rate = parsed['heart_rate']
    if is_fake_kill(heart_rate):
        response.trigger_response()
        return "Fake kill."
    return "Fake kill not triggered."


@app.route('/stop-app', methods=['GET', 'POST'])
def stop_app():
    pass


def extract_json(request_form):
    for jsonString in request_form:
        js = jsonString
        print jsonString
    return json.loads(js)


if __name__ == "__main__":
    app.run(host='0.0.0.0')
