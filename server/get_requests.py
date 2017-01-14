from flask import Flask
from flask import request


app = Flask(__name__)


@app.route('/')
def hello_world():
    return 'Hello, World!'


def accept_location():
    accept_request('location')


def accept_hr():
    accept_request('hr')


def accept_friend_info():
    accept_request('friend-info')


@app.route('/get/<string:address>', methods=['GET', 'POST'])
def accept_request(address):
    content = request.form
    print content
    print content.split()
    return 'hi'
