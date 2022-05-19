/**
* Name: GreenSpace
* Based on the internal empty template. 
* Author: doussin
* Tags: 
*/


model GreenSpace

import "Environnement_Entity.gaml"

species greenSpace parent:environnement_entity{
	string type;
	list attendance <- [0,0,0,0,0,0,0,0,10,10,15,15,15,10,0,0,0,0,0,0,0,0,0,0];
	bool mayLunch <- false;
	float averageTimeSpent <- 15 #minutes;
	
	aspect default
	{
		draw shape color: #darkgreen depth: 1;
	}	
	
}