from map import create_map_url
from twilio import send_text, start_call, generate_twiml, write_twiml_to_file


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
        message = self.generate_start_message()
        send_text(self.contact_number, self.from_number, message)

    def generate_start_message(self):
        return self.contact_name + ", this message is to let you know that your friend " + self.user_name + \
               " has started to track their heart rate to avoid: " + self.cause + \
               ". They put you down as their contact in case anything bad happens. You will be notified by " \
               + self.contact_preference + " if we notice anything peculiar."

    def trigger_response(self):
        message = self.generate_response()
        if self.contact_preference == 'text':
            map_url = create_map_url(self.location)
            send_text(self.contact_number, self.from_number, message, map_url)
        elif self.contact_preference == 'call':
            twiml = generate_twiml(message)
            write_twiml_to_file(twiml, 'static/phone-script.xml')
            script_url = 'http://172.56.17.26:8080/twiml'  # TODO: get this to permanent, working URL
            start_call(self.contact_number, self.from_number, script_url)

    def generate_response(self):
        # TODO: convert lat long to address
        return self.contact_name + ", your friend " + self.user_name + \
               " has reached a dangerous heart rate level. This may be due to: " \
               + self.cause + ".\nThey are located at " + self.location \
               + ". Please respond immediately and consider calling 911."
