from get_requests import get_hr, get_location, get_contact_number
from interpreter import is_overdose
from response import Response

# wait till app starts w/ GPS and friend data

# initialize with GPS and friend data
location = get_location()
contact_number = get_contact_number()
response = Response(location, contact_number)

# continuously check and interpret HR
while True:
    heart_rate = get_hr()
    if is_overdose(heart_rate):
        response.trigger_response()
    else:
        pass

# TODO: migrate to session-based design, server should run continuously
# Session has its own HR list and Response object with location and contact info
# Start a new session each time app is opened, phone POSTs to '/startsession' with location
# '/contact-info' will update the session's number
# During session, continuously check HR at '/hr' and interpret result
# If response triggered, close session (but keep server running)