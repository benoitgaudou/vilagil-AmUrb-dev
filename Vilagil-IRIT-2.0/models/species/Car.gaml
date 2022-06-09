/**
* Name: Car
* Based on the internal empty template. 
* Author: doussin
* Tags: 
*/


model Car

import "Environnement_Entity.gaml"
import "People.gaml"
import "Amenity.gaml"

species car parent:environnement_entity skills:[moving]{
	float speed <- float(one_of(range(20,40))) #km/#h;
	bool isParked <- false;
	agent cible;
	point arrivee;
	float timeSpentHere <- 0.0;
	float timeToSpent;
	agent owner;
	
	reflex hitTheRoad when: isParked = false {
		do goto on:car_graph target:arrivee;
		if arrivee = location {
			if cible is FluxGen{
				do die;
			}
			if cible is parkingPlace {
				isParked <- true;
				ask cible as environnement_entity{
					myself.timeToSpent <- float(youWillSpent());
					do update;
				}
				create student number: 1{
					carOwner <- true;
					location <- myself.location;
					gamos <- myself;
					myself.owner <- self;
					do allUpdate;
					lAction <- lAction + ["goHome"::0.01];
					do perceptionDecision;
				}
			}
		}
	}
	
	reflex timeToGoHome{
		if timeSpentHere > timeToSpent{
			actions <- ["student"::["goHome"]];
			fNeed <- 1.0;
		} else {
			timeSpentHere <- timeSpentHere + step;
		}
	}
	
	action parkMe {
		cible <- one_of(where(parkingPlace, each.availble = true));
		if cible = nil {
			do vroom;
		} else {
			if cible != nil {
				ask cible as parkingPlace {
					availble <- true;
				}
			}
		}
		arrivee <- cible.location;
	}
	
	action vroom {
		actions <- [];
		cible <- one_of(FluxGen);
		arrivee <- cible.location;
		isParked <- false;
		attendance[current_date.hour] <- 0;
		fNeed <- 0.0;
		ask people where(each.final_destination = self){
			self.carOwner <- true;
			do perceptionDecision;
		}
	}
	
	reflex maj {
		if dead(owner){
			do vroom;
		}
	}
	
	aspect default
	{
		draw rectangle(4,2) color: #red depth: 2;
	}
}