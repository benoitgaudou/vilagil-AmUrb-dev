from flask import Flask,jsonify

import  mqtt_client

app = Flask(__name__)

@app.route("/peopleOnTheRoad")
def hello_world():
    nbPeople = mqtt_client.__model.__getData__("peopleOnTheRoad")

    data = {
        "peopleOnTheRoad": nbPeople,
    }

    return jsonify(data)

@app.route("/occupation/<id>")
def hello_world2(id):
    nbPeople = mqtt_client.__model.__getData__(str(id))

    data = {
        "occupation": nbPeople,
    }

    return jsonify(data)

@app.route("/")
def acceuil_chalereux():
    return "Coucou petite perruche"