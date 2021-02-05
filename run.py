from flask import Flask
import requests
app = Flask(__name__)

@app.route('/')
def hello_world():
    print(requests)
    return 'Hello World!'

if __name__ == '__main__':
    app.run()
