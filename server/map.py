def create_map_url(location):
    if location != 'unknown':
        return "https://maps.googleapis.com/maps/api/staticmap?center=" + location + \
               "&zoom=13" \
               "&size=600x300" \
               "&maptype=roadmap" \
               "&markers=color:red%7C%7C" + location + \
               "&key=AIzaSyBfgt8K5q-VmaO5T5lkzgWgZADbbo3kfRk"
