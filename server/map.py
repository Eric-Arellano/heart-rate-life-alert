import requests

def create_map_url(location):
    if location != 'unknown':
        return "https://maps.googleapis.com/maps/api/staticmap?center=" + location + \
               "&zoom=13" \
               "&size=600x300" \
               "&maptype=roadmap" \
               "&markers=color:red%7C%7C" + location + \
               "&key=AIzaSyBfgt8K5q-VmaO5T5lkzgWgZADbbo3kfRk"


def translate_latlong_to_address(latlong):
    url = "https://maps.googleapis.com/maps/api/geocode/json" \
          "?latlng=" + latlong + \
          "&key=AIzaSyBfgt8K5q-VmaO5T5lkzgWgZADbbo3kfRk"
    connection = requests.post(url)
    data = connection.json()
    print data
    return data["formatted_address"]
