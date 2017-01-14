from flask import Flask
from flask import request


app = Flask(__name__)


@app.route('/location', methods=['GET', 'POST'])
def get_location():
    content = request.form
    return "18.231, 38.13813"


@app.route('/hr', methods=['GET', 'POST'])
def get_hr():
    content = request.form
    return 100


@app.route('/contact-number', methods=['GET', 'POST'])
def get_contact_number():
    content = request.form
    return "+19258585614"
