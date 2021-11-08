from flask import Flask,jsonify

import  mqtt_client

app = Flask(__name__)

@app.route("/peopleOnTheRoad")
def hello_world():
    print( mqtt_client.__model.__getData__("peopleOnTheRoad"))
    nbPeople = mqtt_client.__model.__getData__("peopleOnTheRoad")

    data = {
        "peopleOnTheRoad": nbPeople,
    }

    return jsonify(data)

@app.route("/hello")
def hello_world2():
    return "<p>Hello, World! ^^</p>"