import os  # for API Keys

from twilio.rest import TwilioRestClient

account_sid = os.environ.get('TWILIO_ACCOUNT_SID')
auth_token = os.environ.get('TWILIO_AUTH_TOKEN')
client = TwilioRestClient(account_sid, auth_token)


class Response:
    from_number = "+15202144342"

    def __init__(self, location, contact_number="+19258585614"):
        self.location = location
        self.contact_number = contact_number

    def trigger_response(self):
        message = self.create_message()
        self.send_text(self.contact_number, self.from_number, message)

    def create_message(self):
        return "WARNING: your friend has overdosed. Please respond immediately."

    @staticmethod
    def send_text(to, from_, message):
        message = client.messages.create(to=to, from_=from_, body=message)
        print(message.sid)


response = Response("Tucson")
response.trigger_response()
