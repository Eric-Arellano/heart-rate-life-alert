import os  # for API Keys

from twilio.rest import TwilioRestClient

from map import create_map_url

account_sid = os.environ.get('TWILIO_ACCOUNT_SID')
auth_token = os.environ.get('TWILIO_AUTH_TOKEN')
client = TwilioRestClient(account_sid, auth_token)


class Response:
    from_number = "+15202144342"

    def __init__(self,
                 user_name="Abhik Chowdhury",
                 location="unknown",
                 contact_number="+19258585614",
                 contact_name="Eric",
                 contact_preference="text",
                 cause="overdose"):
        self.user_name = user_name
        self.location = location
        self.contact_number = contact_number
        self.contact_name = contact_name
        self.contact_preference = contact_preference
        self.cause = cause

    def notify_contact_of_start(self):
        message = self.contact_name + ", this message is to let you know that your friend " + self.user_name + \
                  " has started to track their heart rate to avoid: " + self.cause + \
                  ". They put you down as their contact in case anything bad happens. You will be notified by " \
                  + self.contact_preference + "if we notice anything peculiar."
        self.send_text(self.contact_number, self.from_number, message)

    def trigger_response(self):
        # TODO: convert lat long to address
        message = self.contact_name + ", your friend " + self.user_name + \
                  " has reached a dangerous heart rate level. This may be: " \
                  + self.cause + ".\nThey are located at " + self.location \
                  + ". Please respond immediately and consider calling 911."
        map_url = create_map_url(self.location)
        self.send_text(self.contact_number, self.from_number, message, map_url)

    @staticmethod
    def send_text(to, from_, message, map_url=None):
        message = client.messages.create(to=to, from_=from_, body=message, media_url=map_url)
        print(message.sid)

        # TODO: Add calls
