from twilio.rest import TwilioRestClient
import os  # for API Keys

account_sid = os.environ.get('TWILIO_ACCOUNT_SID')
auth_token = os.environ.get('TWILIO_AUTH_TOKEN')
client = TwilioRestClient(account_sid, auth_token)


def trigger_response():
    from_number = get_from_number()
    to_number = get_to_number()
    message = get_message()
    send_text(message, to_number, from_number)


def send_text(from_, to, message):
    message = client.messages.create(body=message,
                                     to=to,
                                     from_=from_)
    print(message.sid)


def get_from_number():
    return "+15203917018"


def get_to_number():
    return "+19258585614"


def get_message():
    return "SOS I NEED HELP ABHIK"

trigger_response()
