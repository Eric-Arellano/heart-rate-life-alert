import os  # for API Keys

from twilio.rest import TwilioRestClient

from twilio import twiml

account_sid = os.environ.get('TWILIO_ACCOUNT_SID')
auth_token = os.environ.get('TWILIO_AUTH_TOKEN')
client = TwilioRestClient(account_sid, auth_token)


def send_text(to, from_, message, map_url=None):
    message = client.messages.create(to=to, from_=from_, body=message, media_url=map_url)
    print(message.sid)


def start_call(to, from_, script_url):
    call = client.calls.create(to=to, from_=from_, url=script_url)
    print(call.sid)


def generate_twiml(message):
    response = twiml.Response()
    response.say(message)
    return str(response)


def write_twiml_to_file(message, filename):
    with open(filename, 'w') as file:
        file.write(message)
    file.close()
