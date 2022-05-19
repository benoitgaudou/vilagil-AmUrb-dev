/**
* Name: Building
* Based on the internal empty template. 
* Author: doussin
* Tags: 
*/


model Building

import "../Vilagil_inhabitants2_0.gaml"
import "People.gaml"
import "FluxGenerator.gaml"
import "Environnement_Entity.gaml"
import "Building.gaml"

/* Insert your model definition here */

species building parent:environnement_entity{
	int toManyPeople <- 100;
	int flats <- 2;
	string type;
	string name;
//	int maxPeopleInside;
	map<string,list> actions <- ["student"::["study"], "professor"::["work"]];
	list attendance <- [0,0,0,0,0,0,0,20,30,60,50,40,30,40,50,50,30,20,10,10,0,0,0,0];
	
	aspect default
	{
		draw shape color: (type = "RU")?#red:#grey depth: (1 + flats) * 6;
	}
}