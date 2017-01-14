from flask import Flask
import twilio.twiml
import os  # for API Keys

account_sid = os.environ.get('TWILIO_ACCOUNT_SID')
auth_token = os.environ.get('TWILIO_AUTH_TOKEN')

app = Flask(__name__)


def trigger_response():
    pass
