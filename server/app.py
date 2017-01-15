import simplejson as json
from flask import Flask
from flask import request

from interpreter import is_overdose
from response import Response

app = Flask(__name__)

heart_rates = []
response = Response()


@app.route('/dashboard', methods=['GET'])
def start_session():
    return ", ".join(heart_rates)


@app.route('/location', methods=['GET', 'POST'])
def get_location():
    # get data
    raw = request.form
    for jsonString in raw:
        js = jsonString
        print jsonString
    parsed = json.loads(js)
    latitude = parsed['latitude']
    longitude = parsed['longitude']
    # return
    response.location = str(latitude) + "," + str(longitude)
    return "Location received."


@app.route('/hr', methods=['GET', 'POST'])
def get_hr():
    # get data
    raw = request.form
    for jsonString in raw:
        js = jsonString
        print jsonString
    parsed = json.loads(js)
    heart_rate = parsed['heart_rate']
    date = parsed['date']
    time = parsed['time']
    # return
    heart_rates.append(heart_rate)
    if is_overdose(heart_rate):
        response.trigger_response()
        return "Overdose."
    return "HR okay."


@app.route('/contact-info', methods=['GET', 'POST'])
def get_contact_number():
    raw = request.form
    for jsonString in raw:
        js = jsonString
        print jsonString
    parsed = json.loads(js)
    response.contact_number = "+1" + parsed['contact_number']
    response.contact_name = parsed['contact_name']
    response.contact_preference = parsed['contact_preference']
    response.cause = parsed['contact_cause']
    return 'Contact preferences received.'


@app.route('/stop', methods=['GET', 'POST'])
def stop_app():
    pass


if __name__ == "__main__":
    app.run(host='0.0.0.0')
