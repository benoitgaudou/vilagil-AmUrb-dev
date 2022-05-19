/**
* Name: Bicycle
* Based on the internal empty template. 
* Author: doussin
* Tags: 
*/


model Bicycle

import "Environnement_Entity.gaml"
import "People.gaml"
import "Amenity.gaml"

species bicycle parent:environnement_entity skills:[moving]{
	float speed <- float(one_of(range(5,12))) #km/#h;
	bool isParked <- false;
	agent cible;
	point arrivee;
	float timeSpentHere <- 0.0;
	
	reflex hitTheRoad when: isParked = false {
		do goto on:the_graph target:arrivee;
		if arrivee = location {
			if cible is FluxGen{
				ask student where(each.final_destination = self){
					do perceptionDecision;
				}
				do die;
			}
			if cible is bicyclePlace {
				isParked <- true;
				create student number: 1{
					location <- myself.location;
					do perceptionDecision;
				}
			}
		}
	}
	
	reflex timeToGoHome{
		if timeSpentHere > (cible as environnement_entity).averageTimeSpent {
			actions <- ["people"::["goHome"]];
//			timeSpentHere <- 0.0;
//			ask cible as bicyclePlace {
//				availble <- true;
//			}
		} else {
			timeSpentHere <- timeSpentHere + step;
		}
	}
	
	action update{
		if actions = ["people"::["goHome"]]{ 
			fNeed <- 1.0;
		}
	}
	
	action parkMe {
		cible <- one_of(where(bicyclePlace, each.availble = true));
		if cible = nil {
			do vroom;
		} else {
			ask cible as bicyclePlace {
				availble <- false;
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
			do perceptionDecision;
		}
	}
	
	aspect default
	{
		draw (isParked = true)?rectangle(1,2) + sphere(1):rectangle(1,2) color: #purple depth: 0.5;
	}	
}