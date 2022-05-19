/**
* Name: FoodTruck
* Based on the internal empty template. 
* Author: doussin
* Tags: 
*/


model FoodTruck

import "Environnement_Entity.gaml"

/* Insert your model definition here */

species foodTruck parent:environnement_entity{
	int toManyPeople <- 20;
	string type;
	string name;
	map<string,list> actions <- ["student"::["eat"]];
	list attendance <- [0,0,0,0,0,0,0,0,0,0,0,10,10,0,0,0,0,0,0,0,0,0,0,0];
	
	aspect default
	{
		draw shape color: #black depth: 5;
	}
}