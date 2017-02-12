# Heart Rate Life Alert
Project for HackArizona 2017.

## What it does
Interfaces with Apple Watch to continually check heart rate for critical emergency condition (like heart attack), and upon trigger sends text message with current location to trusted contact. 

## How to run
1. in ```server/``` directory, ```pip install -r requirements.txt```
1. export API keys in bash
    1. ```export TWILIO_ACCOUNT_SID="example"```
    1. ```export TWILIO_AUTH_TOKEN="example"```
    1. ```export GOOGLE_KEY="example"```
1. connect server and iPhone to same WiFi network/hotspot
1. connect iPhone with Apple Watch to laptop with XCode
1. build iOS app through XCode
1. in ```server/``` directory, launch server by running ```app.py```

## What I learned
- Working with stack of multiple languages. Used both Swift and Python
- JSON and HTTP requests
- Flask practice
- Basics of Swift and Healthkit 