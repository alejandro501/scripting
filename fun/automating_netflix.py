import requests
import json
import smtplib

# Function to check for new episodes of "Break Point" on Netflix
def check_for_new_episodes():
    # URL for the Netflix API
    url = "https://unogs-unogs-v1.p.rapidapi.com/aaapi.cgi?q=get:new7:US&p=1"

    # Headers for the API request
    headers = {
        "X-RapidAPI-Key": "SIGN-UP-FOR-KEY",
        "X-RapidAPI-Host": "unogs-unogs-v1.p.rapidapi.com"
    }

    # Make the API request
    response = requests.get(url, headers=headers)

    # Parse the JSON response
    data = json.loads(response.text)

    # Check if "Break Point" is in the list of new releases
    for item in data["ITEMS"]:
        if item["title"].lower() == "break point":
            send_email()
            break

# Function to send an email
def send_email():
    # Email credentials
    from_email = "your_email@example.com"
    from_password = "your_email_password"
    to_email = "your_email@example.com"

    # Email message
    subject = "New episodes of Break Point on Netflix"
    body = "There are new episodes of Break Point available on Netflix. Go watch them now!"

    # Send the email
    server = smtplib.SMTP("smtp.gmail.com", 587)
    server.starttls()
    server.login(from_email, from_password)
    server.sendmail(from_email, to_email, f"Subject: {subject}\n\n{body}")
    server.quit()

# Run the program
check_for_new_episodes()