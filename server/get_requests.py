from flask import Flask
from flask import request


app = Flask(__name__)


@app.route('/startsession', methods=['GET', 'POST'])
def start_session():
    pass


@app.route('/location', methods=['GET', 'POST'])
def get_location():
    connection = request.form
    data = connection.json()
    latitude = data[0]
    longitude = data[1]
    return str(latitude) + ", " + str(longitude)


@app.route('/hr', methods=['GET', 'POST'])
def get_hr():
    connection = request.form
    data = connection.json()
    heart_rate = data[3]
    return heart_rate
    # TODO: for now, ignoring date/time value


@app.route('/contact-number', methods=['GET', 'POST'])
def get_contact_number():
    content = request.form
    return "+19258585614"


@app.route('/overdose', methods=['GET', 'POST'])
def warn_overdose():
    pass
