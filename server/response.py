import os  # for API Keys

from twilio.rest import TwilioRestClient

from map import create_map_url

account_sid = os.environ.get('TWILIO_ACCOUNT_SID')
auth_token = os.environ.get('TWILIO_AUTH_TOKEN')
client = TwilioRestClient(account_sid, auth_token)


class Response:
    from_number = "+15202144342"

    def __init__(self, location="unknown", contact_number="+19258585614", contact_name="Eric"):
        self.location = location
        self.contact_number = contact_number
        self.contact_name = contact_name

    # TODO: add initiation text

    def trigger_response(self):
        message = self.contact_name + ", your friend has overdosed. They are located at " + self.location \
                  + ". Please respond immediately."
        map_url = create_map_url(self.location)
        self.send_text(self.contact_number, self.from_number, message, map_url)

    @staticmethod
    def send_text(to, from_, message, map_url=None):
        message = client.messages.create(to=to, from_=from_, body=message, media_url=map_url)
        print(message.sid)

        # TODO: Add calls
