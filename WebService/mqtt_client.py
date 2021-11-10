import paho.mqtt.client as mqtt #import the client1
import html
import xml.etree.ElementTree as ET

from model import Model

__model = Model()


############
def on_message(client, userdata, message):
    #print("message received " ,str(message.payload.decode("utf-8")))
    #print("message topic=",message.topic)
    #print("message qos=",message.qos)
    #print("message retain flag=",message.retain)

    mess = message.payload.decode("utf-8")

def on_message_peopleOnTheRoad(client, userdata, message):
    mess = html.unescape(message.payload.decode("utf-8")).splitlines()
    mess.pop(0)
    mess.pop(0)
    mess.pop(0)
    mess = ''.join(mess)
    root = ET.fromstring(mess)
    for child in root.iter('int'):
        __model.__updateData__('peopleOnTheRoad',float(child.text))

def on_message_building_occupation(client, userdata, message):
    mess = html.unescape(message.payload.decode("utf-8")).splitlines()
    mess.pop(0)
    mess.pop(0)
    mess.pop(0)
    mess = ''.join(mess)
    root = ET.fromstring(mess)
    for child in root.iter('string'):
        list1 = list(child.text.split())
        list2 = list(map(int, list1))
        building = message.topic.replace("dynamic/buildings/occupation/", '')
        __model.__updateData__(building, list2)
########################################

broker_address="localhost"
#broker_address="iot.eclipse.org"

print("creating new instance")
client = mqtt.Client("P1") #create new instance
client.on_message=on_message #attach function to callback

client.message_callback_add("dynamic/metric/peopleOnTheRoad", on_message_peopleOnTheRoad)
client.message_callback_add("dynamic/buildings/occupation/#", on_message_building_occupation)

print("connecting to broker")
client.connect(broker_address) #connect to broker

print("Subscribing to topic","dynamic/metric/peopleOnTheRoad")
client.subscribe("dynamic/metric/peopleOnTheRoad",0)

print("Subscribing to topic","dynamic/buildings/occupation/*")
client.subscribe("dynamic/buildings/occupation/#",0)


client.loop_start()