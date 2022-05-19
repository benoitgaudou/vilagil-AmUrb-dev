/**
* Name: Road
* Based on the internal empty template. 
* Author: doussin
* Tags: 
*/


model Road

import "Environnement_Entity.gaml"

species road parent:environnement_entity{
	string type;
	string name;
	
	aspect default
	{
		draw shape color: #black;
	}
}