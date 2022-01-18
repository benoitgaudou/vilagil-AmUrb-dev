# vilagil-AmUrb-dev

This repository contains ressources of the Vilagil-AmUrb project:
* The `Vilagil-CampusUPS` contains a simple GAMA model on the UPS Campus.


## Run the GAMA model

The model has been designed on the GAMA platform in its version 1.8.1, [that can be downloaded from the GAMA official website](https://gama-platform.github.io/download). Note : for any operating system but MacOs Big Sure, take  the "With JDK"  version (for  Big Sure user, [take the 1.8.2 alpha release](https://github.com/gama-platform/gama/releases/tag/1.8.2).

To  run the model:
* Download/clone this repository.
* Download GAMA platform, and unzip it.
* Launch GAMA and chose a workspace (repository where your projects will be created).
* Right-click  on User models (right pane), Import... > GAMA project. Click on Browse button to find the `Vilagil-CampusUPS`. OK.
* To run the model, open the  new  folder Vilagil-CampusUPS in User models, and in the models folder, double-click on `Vilagil - inhabitants.gaml`.
* Click on the green button:
  * `interactive` to launch the interactive simulation (you right click on the environnement to create building, on buildings to add floors ...
  *  `multi` to  launch the experiment comparing 3 simulations.

To  run the webservice:
* Install a mqtt broker (for example : https://mosquitto.org/download/)
* Run the brocker (for example: mosquitto.exe)
* In your python environment, install the two following dependencies
  * pip install paho-mqtt
  * pip install -U Flask
* To run the application, use the flask command or python -m flask. Before you can do that you need to tell your terminal the application to work with by exporting the FLASK_APP environment variable:
  * BASH: export FLASK_APP=hello   
  * CMD : set FLASK_APP=hello   
  * Powershell: $env:FLASK_APP = "hello"
* Run the flask server (https://flask.palletsprojects.com/en/2.0.x/)
  * flask run

To make a post requests:
* You must send a message to the 'mailbox' topic. The different possible requests are documented in the mqtt_client.py file