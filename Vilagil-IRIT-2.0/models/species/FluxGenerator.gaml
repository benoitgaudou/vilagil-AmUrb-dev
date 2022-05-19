/**
* Name: FluxGenerator
* Based on the internal empty template. 
* Author: doussin
* Tags: 
*/

model FluxGenerator

/* Insert your model definition here */

import "../Vilagil_inhabitants2_0.gaml"
import "People.gaml"
import "FluxGenerator.gaml"
import "Environnement_Entity.gaml"
import "Building.gaml"
import "Green_Space.gaml"
import "Amenity.gaml"
import "Road.gaml"
import "Car.gaml"
import "Bicycle.gaml"
import "BusStop.gaml"
import "FoodTruck.gaml"

species FluxGen parent: environnement_entity{
	bool carCreator <- false;
	
	// Affluence en dur
	list affluencePeople <- list_with(24,0);
	list affluenceCar <- list_with(24,0);
	list affluenceCycle <- list_with(24,0);
	
	// Nouvelle fonction de calcule
	list affluence <- list_with(24,0);
	float importance <- 0.2;
//	float carPro <- 0.1;
	
	// Nb de personne à faire pop
	int calcAfflu;
	float fNeed <- 0.0;
	
	//Génération des bus
	bool busGen <- false;
	float freqBus;
	float lastPop <- float(one_of(range(freqBus)));
	int comeInBus;
	
	// Liste des actions permises par l'entité
	map<string,list> actions <- ["student"::["goHome"], "professor"::["goHome"]];
	
	init {
		//The Old way, la génération de personne dépend du nombre attendu dans la zone
//		ask agents of_generic_species(environnement_entity){
//			loop k from: 0 to: 23 {
//				myself.affluence[k] <- myself.affluence[k] + self.attendance[k] * myself.importance;
//			}
//		}
	}
	
	reflex majAffluence {
		affluence <- list_with(24,int(peopleInTheHour/6));
//		write affluence;
	}

	action update {
		fNeed <- 0.01;
	}
	
	reflex popBus when: busGen = true{
		if lastPop < freqBus {
			lastPop <- lastPop + step;
		} else {
			create Bus number:1{
				startingPoint <- myself;
				location <- myself.location;
				peopleInside <- myself.comeInBus;
			}
			comeInBus <- 0;
			lastPop <- 0.0;
		}
	}
		
	reflex popStudent {
//		write affluence[current_date.hour]/( 1 #h / step );
		if affluence[current_date.hour]/( 1 #h / step )  < 1 {
			if flip(affluence[current_date.hour]/( 1 #h / step )){
				calcAfflu <- 1;
			}
		} else if flip( (affluence[current_date.hour] mod ( 1 #h / step ))/( 1 #h / step ) ) {
			calcAfflu <- int(floor(affluence[current_date.hour]/( 1 #h / step ))) + 1 ;
		} else {
			calcAfflu <- int(floor(affluence[current_date.hour]/( 1 #h / step )));
		}
		int pieton <- calcAfflu;
		if calcAfflu != 0 {
			loop k from: 0 to: calcAfflu {
				if flip(busPerCent){
					if busGen {
						comeInBus <- comeInBus + 1;
						pieton <- pieton - 1;
					}else{
						ask one_of(FluxGen where (each.busGen = true)){
							comeInBus <- comeInBus + 1;
						}
					}
				} else if flip(carPerCent){
					create car number: 1{
						location <- myself.location;
						do parkMe;
					}
					pieton <- pieton - 1;
				}
			}
		}
		available <- false;
		create student number: pieton{
//			write self;
			if flip(ego){
				egoiste <- true;
			}
			location <- myself.location;
			do allUpdate;
			do perceptionDecision;
		}
		available <- true;
		calcAfflu <- 0;
	}
	
	aspect simple {
		draw circle(6) color: #pink border: #black;
	}	
}

