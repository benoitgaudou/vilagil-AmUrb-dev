/**
* Name: BusStop
* Based on the internal empty template. 
* Author: doussin
* Tags: 
*/


model BusStop

/* Insert your model definition here */

import "Environnement_Entity.gaml"

species busStop parent:environnement_entity{
	map<string,list> actions <- ["student"::["goHome"]];
	
	aspect default
	{
		draw shape color: #purple;
	}	
}


//Utiliser le skill public_transport
species Bus parent: environnement_entity skills:[moving]{
	float speed <- float(one_of(range(20,40))) #km/#h;
	list<busStop> arret;
	int nextStopNb <- 0;
	FluxGen startingPoint;
	FluxGen endingPoint;
	point nextStop;
	bool justStop <- false;
	int peopleInside;
	
	init {
		arret <- [closest_to(busStop, self)];
		arret <- arret + [closest_to(busStop, arret[0])];
		endingPoint <- closest_to(FluxGen, last(arret));
		nextStop <- any_location_in(arret[0]);
	}
	
	reflex onTheRoad {
		if justStop {
			justStop <- false;
		} else if location = nextStop {
			if nextStopNb >= length(arret){
				do die;
			} else {
				create student number: peopleInside{
					location <- myself.location;
					lAction <- ["study"::1.0, "goHome"::0.0, "eat"::0.0];
					do updateEatDesire;
					do perceptionDecision;
				}
				peopleInside <- 0;
				justStop <- true;
				nextStopNb <- nextStopNb + 1;
				if nextStopNb >= length(arret){
					nextStop <- any_location_in(endingPoint);
				} else {
					nextStop <- any_location_in(arret[nextStopNb]);
				}	
			}
		} else {
			do goto on:the_graph target:nextStop;
		}
	}
	
	aspect default
	{
		draw rectangle(8,3) color: #turquoise depth: 3;
	}
}