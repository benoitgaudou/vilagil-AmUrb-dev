from flask import Flask,jsonify, request

import  mqtt_client

app = Flask(__name__)

@app.route("/peopleOnTheRoad")
def hello_world():
    nbPeople = mqtt_client.__model.__getData__("peopleOnTheRoad")

    data = {
        "peopleOnTheRoad": nbPeople,
    }

    return jsonify(data)

@app.route("/buildingList")
def hello_world3():
    l = mqtt_client.__model.__getData__("buildingList")

    data = {
        "buildingList": l,
    }

    return jsonify(data)

@app.route("/occupation/<id>")
def hello_world2(id):
    nbPeople = mqtt_client.__model.__getData__(str(id))

    data = {
        "occupation": nbPeople,
    }

    return jsonify(data)

@app.route("/mailbox")
def mailbox():
    type = request.args.get('type')
    data1 = request.args.get('data1')
    data2 = request.args.get('data2')
    if type == None: 
        message = mqtt_client.__model.__getData__("mailbox")

        data = {
            "mailbox": message,
        }

        return jsonify(data)
    elif data2 == None:
        if type == "changeSteps":
            timeStep = ''.join(filter(lambda x: x.isdigit(), data1)) + "#" + ''.join(filter(lambda x: not x.isdigit(), data1))
            mqtt_client.client.publish("mailbox",str(type + " " + timeStep))
        else :
            mqtt_client.client.publish("mailbox",str(type + " " + data1))

        return "Message Sent"
    else :
        mqtt_client.client.publish("mailbox",str(type + " " + data1 + " " + data2))

        return "Message Sent"

@app.route("/mailbox/<msg>")
def mailboxMsg(msg):
    mqtt_client.client.publish("mailbox",str(msg).replace("&"," "))

    return "Message Sent"

@app.route("/")
def acceuil_chalereux():
    return "Coucou petite perruche"