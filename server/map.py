import os  # for API keys

import requests

google_key = os.environ.get('GOOGLE_KEY')

def create_map_url(location):
    if location != 'unknown':
        return "https://maps.googleapis.com/maps/api/staticmap?center=" + location + \
               "&zoom=13" \
               "&size=600x300" \
               "&maptype=roadmap" \
               "&markers=color:red%7C%7C" + location + \
               "&key=" + google_key


def translate_latlong_to_address(latlong):
    url = "https://maps.googleapis.com/maps/api/geocode/json" \
          "?latlng=" + latlong + \
          "&key=" + google_key
    connection = requests.post(url)
    data = connection.json()
    print data
    return data["formatted_address"]
