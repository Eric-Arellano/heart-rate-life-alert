from flask import Flask
from flask import request
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'


@app.route('/location', methods=['GET', 'POST'])
def accept_gps():
    content = request.form
    print content
    print content.split()
    return 'hi'


@app.route('/hr', methods=['GET', 'POST'])
def accept_hr():
    content = request.form
    print content
    print content.split()
    return 'hi'


@app.route('/hr', methods=['GET', 'POST'])
def accept_friend_info():
    content = request.form
    print content
    print content.split()
    return 'hi'
