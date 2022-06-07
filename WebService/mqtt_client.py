from markupsafe import string
import paho.mqtt.client as mqtt #import the client1
import html
import xml.etree.ElementTree as ET

from model import Model

__model = Model()


############
def on_message(client, userdata, message):
    mess = message.payload.decode("utf-8")

#Avec par exemple : changeColor buildingX blue
# ou : changeNbFlats buildingX int
# ou : changeSteps 2#h (fonctionne avec 30#minute)
# ou : changePeopleFlats buildingX int
def on_message_mail(client, userdata, message):
    mess = message.payload.decode("utf-8")
    __model.__updateData__('mailbox',mess)

def on_message_peopleOnTheRoad(client, userdata, message):
    root = unencryptGama(message)
    for child in root.iter('int'):
        __model.__updateData__('peopleOnTheRoad',float(child.text))

def on_message_bus_use(client, userdata, message):
    root = unencryptGama(message)
    list1 = []
    for child in root.iter('string'):
        list1 += list(child.text.split())
    __model.__updateData__('busUse',list1)

def on_message_people_by_hour(client, userdata, message):
    root = unencryptGama(message)
    list1 = []
    for child in root.iter('string'):
        list1 += list(child.text.split())
    __model.__updateData__('peopleByHour',list1)

def on_message_world_shape(client, userdata, message):
    root = unencryptGama(message)
    list1 = []
    for child in root.iter('string'):
        list1 += list(child.text.split())
    __model.__updateData__('worldShape',list1)

def on_message_car_use(client, userdata, message):
    root = unencryptGama(message)
    list1 = []
    for child in root.iter('string'):
        list1 += list(child.text.split())
    __model.__updateData__('carUse',list1)

def on_message_building_list(client, userdata, message):
    root = unencryptGama(message)
    list1 = []
    for child in root.iter('string'):
        list1 += list(child.text.split())
    __model.__updateData__("buildingList", list1)

def on_message_fluxgen_list(client, userdata, message):
    root = unencryptGama(message)
    list1 = []
    for child in root.iter('string'):
        list1 += list(child.text.split())
    __model.__updateData__("fluxGenList", list1)

def on_message_parking_list(client, userdata, message):
    root = unencryptGama(message)
    list1 = []
    for child in root.iter('string'):
        list1 += list(child.text.split())
    __model.__updateData__("parkingList", list1)

def on_message_fluxgen_location(client, userdata, message):
    root = unencryptGama(message)
    list1 = []
    for child in root.iter('string'):
        list1 += list(child.text.split())
        location = message.topic.replace("static/FluxGen/location/", '')
        location += "location"
    __model.__updateData__(location, list1)

def on_message_buildings_location(client, userdata, message):
    root = unencryptGama(message)
    list1 = []
    for child in root.iter('string'):
        list1 += list(child.text.split())
        location = message.topic.replace("static/buildings/location/", '')
        location += "location"
    __model.__updateData__(location, list1)

def on_message_building_occupation(client, userdata, message):
    root = unencryptGama(message)
    list1 = []
    for child in root.iter('string'):
        list1 += list(child.text.split())
        building = message.topic.replace("dynamic/buildings/occupation/", '')
        building += "occupation"
    __model.__updateData__(building, list1)

def on_message_parking_occupation(client, userdata, message):
    root = unencryptGama(message)
    list1 = []
    for child in root.iter('string'):
        list1 += list(child.text.split())
        park = message.topic.replace("dynamic/parking/occupation/", '')
        park += "occupation"
    __model.__updateData__(park, list1)

def on_message_building_type(client, userdata, message):
    root = unencryptGama(message)
    list1 = []
    for child in root.iter('string'):
        list1 += list(child.text.split())
        building = message.topic.replace("static/buildings/type/", '')
    __model.__updateData__(building, list1)

def on_message_parking_type(client, userdata, message):
    root = unencryptGama(message)
    list1 = []
    for child in root.iter('string'):
        list1 += list(child.text.split())
        park = message.topic.replace("static/parking/type/", '')
    __model.__updateData__(park, list1)

def on_message_bus_freq(client, userdata, message):
    root = unencryptGama(message)
    list1 = []
    for child in root.iter('string'):
        list1 += list(child.text.split())
        freq = message.topic.replace("static/FluxGen/busFreq/", '')
    __model.__updateData__(freq, list1)

def unencryptGama(message):
    mess = html.unescape(message.payload.decode("utf-8")).splitlines()
    mess.pop(0)
    mess.pop(0)
    mess.pop(0)
    mess = ''.join(mess)
    root = ET.fromstring(mess)
    return root
########################################

broker_address="localhost"
#broker_address="iot.eclipse.org"

print("creating new instance")
client = mqtt.Client("P1") #create new instance
client.on_message=on_message #attach function to callback

client.message_callback_add("dynamic/metric/peopleOnTheRoad", on_message_peopleOnTheRoad)
client.message_callback_add("dynamic/buildings/occupation/#", on_message_building_occupation)
client.message_callback_add("dynamic/parking/occupation/#", on_message_parking_occupation)
client.message_callback_add("static/buildings/list", on_message_building_list)
client.message_callback_add("static/FluxGen/list", on_message_fluxgen_list)
client.message_callback_add("static/parking/list", on_message_parking_list)
client.message_callback_add("static/FluxGen/location/#", on_message_fluxgen_location)
client.message_callback_add("static/buildings/location/#", on_message_buildings_location)
client.message_callback_add("static/buildings/type/#", on_message_building_type)
client.message_callback_add("static/parking/type/#", on_message_parking_type)
client.message_callback_add("static/metric/busUse", on_message_bus_use)
client.message_callback_add("static/metric/carUse", on_message_car_use)
client.message_callback_add("static/metric/peopleByHour", on_message_people_by_hour)
client.message_callback_add("static/metric/worldShape", on_message_world_shape)
client.message_callback_add("static/FluxGen/busFreq/#", on_message_bus_freq)
client.message_callback_add("mailbox", on_message_mail)

print("connecting to broker")
client.connect(broker_address) #connect to broker

print("Subscribing to topic","mailbox")
client.subscribe("mailbox",0)

print("Subscribing to topic","static/#")
client.subscribe("static/#",0)

print("Subscribing to topic","dynamic/#")
client.subscribe("dynamic/#",0)

client.loop_start()