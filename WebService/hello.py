from sqlite3 import Timestamp
from flask import Flask,jsonify, request

import  mqtt_client

app = Flask(__name__)

@app.route("/peopleOnTheRoad")
def peopleOnTheRoad():
    nbPeople = mqtt_client.__model.__getData__("peopleOnTheRoad")

    data = {
        "peopleOnTheRoad": nbPeople,
    }

    return jsonify(data)

@app.route("/fluxGenList")
def fluxGenList():
    l = mqtt_client.__model.__getData__("fluxGenList")

    data = {
        "fluxGenList": l,
    }

    return jsonify(data)

@app.route("/location/<id>")
def location(id):
    location = mqtt_client.__model.__getData__(str(id) + "location")

    data = {
        "location": location,
    }

    return jsonify(data)

@app.route("/buildingList")
def buildingList():
    l = mqtt_client.__model.__getData__("buildingList")

    data = {
        "buildingList": l,
    }

    return jsonify(data)

@app.route("/parkingList")
def parkingList():
    l = mqtt_client.__model.__getData__("parkingList")

    data = {
        "parkingList": l,
    }

    return jsonify(data)

@app.route("/busUse")
def busUse():
    l = mqtt_client.__model.__getData__("busUse")

    data = {
        "busUse": l,
    }

    return jsonify(data)

@app.route("/worldShape")
def worldShape():
    l = mqtt_client.__model.__getData__("worldShape")

    data = {
        "WorldShape": l,
    }

    return jsonify(data)

@app.route("/carUse")
def carUse():
    l = mqtt_client.__model.__getData__("carUse")

    data = {
        "carUse": l,
    }

    return jsonify(data)

@app.route("/type/<id>")
def building_type(id):
    type = mqtt_client.__model.__getData__(str(id))

    data = {
        "type": type,
    }

    return jsonify(data)

@app.route("/occupation/<id>")
def building_occupation(id):
    nbPeople = mqtt_client.__model.__getData__(str(id) + "occupation")

    data = {
        "occupation": nbPeople,
    }

    return jsonify(data)

@app.route("/busFreq/<id>")
def flux_gen_freq_bus(id):
    bus = mqtt_client.__model.__getData__(str(id))

    data = {
        "Frequence des Bus": bus,
    }

    return jsonify(data)

@app.route("/peopleByHour")
def people_by_h():
    message = mqtt_client.__model.__getData__("peopleByHour")

    data = {
        "peopleByHour": message,
    }

    return jsonify(data)

@app.route("/mailbox")
def mailbox():
    message = mqtt_client.__model.__getData__("mailbox")

    data = {
        "mailbox": message,
    }

    return jsonify(data)

@app.route("/mailbox/<msg>")
def mailboxMsg(msg):
    message = str(msg).replace("&"," ")
    tab = message.split(" ")
    if tab[0] == "changeFreqBus":
        tab[2] = ''.join(filter(lambda x: x.isdigit(), tab[2])) + "#" + ''.join(filter(lambda x: not x.isdigit(), tab[2]))
        mqtt_client.client.publish("mailbox",str(tab[0] + " " + tab[1] + " " + tab[2]))
        print(str(tab[0] + " " + tab[1] + " " + tab[2]))
    else :
        mqtt_client.client.publish("mailbox",message)

    return "Message Sent"

@app.route("/")
def acceuil_chalereux():
    return "Coucou petite perruche"