import modal
from modal import Image

# Setup

app = modal.App("hello")
image = Image.debian_slim().pip_install("requests")

# Hello!

@app.function(image=image)
def hello() -> str:
    import requests
    
    response = requests.get('https://ipinfo.io/json')
    data = response.json()
    city, region, country = data['city'], data['region'], data['country']
    return f"Hello from {city}, {region}, {country}!!"

def runLocal():
    with app.run():
        reply=hello.local()
    print(reply)

def runRemote():
    with app.run():
        reply=hello.remote()
    print(reply)

if __name__ == '__main__':
    # runLocal()
    runRemote()