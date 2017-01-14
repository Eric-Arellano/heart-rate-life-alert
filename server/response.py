import os  # for API Keys

from twilio.rest import TwilioRestClient

account_sid = os.environ.get('TWILIO_ACCOUNT_SID')
auth_token = os.environ.get('TWILIO_AUTH_TOKEN')
client = TwilioRestClient(account_sid, auth_token)


def trigger_response():
    # get values
    to_number = get_to_number()
    from_number = get_from_number()
    message = get_message()

    # send text
    send_text(to_number, from_number, message)


def send_text(to, from_, message):
    message = client.messages.create(to=to,
                                     from_=from_,
                                     body=message)
    print(message.sid)


def get_from_number():
    return "+15202144342"


def get_to_number():
    return "+19258585614"


def get_message():
    return "WARNING: your friend has overdosed. Please respond immediately."


trigger_response()
