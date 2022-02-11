/**
* Name: People
* Based on the internal empty template. 
* Author: doussin
* Tags: 
*/


model People

import "FluxGenerator.gaml"

/* Insert your model definition here */

species people skills: [moving] {
	float speed <- float(one_of(range(2,4))) #km/#h;
	agent final_destination;
	float timeSpentHere <- 0.0;
	point arrivee;
	string currentAction;
	
	reflex move when: location != arrivee {
		do goto on:the_graph target:arrivee;
	}
	
	reflex helpStepBroIMStuck when: current_edge = nil {
		do die;
	}
	
	reflex tictac when: location = arrivee and !(final_destination is FluxGen) {
		if final_destination in car {
			ask final_destination as car{
				do vroom;
			}
			do die;
		}
		if timeSpentHere > (final_destination as environnement_entity).averageTimeSpent {
			do wichActionIWannaDo;
			timeSpentHere <- 0.0;
		} else {
			timeSpentHere <- timeSpentHere + step;
		}
	}
	
	reflex jeMeMeurs when:location = final_destination.location and final_destination is FluxGen {
//		write "finito";
		do die;
	}
	
	
	//TODO A refaire parce que c'est pas ça que je veux
	action wichActionIWannaDo{
//		write of_generic_species(agents, environnement_entity) sum_of each.actions;
		list listALaMano <- [];
		ask of_generic_species(agents, environnement_entity){
			if self is greenSpace and fNeed = 0 {}
			else {
				listALaMano <- listALaMano + actions;
			}
		}
		currentAction <- one_of(remove_duplicates(listALaMano));
		do choose_entity (currentAction);
	}
	
	action choose_entity (string Act){
		list possibleEntity <- where(of_generic_species(agents, environnement_entity), in(Act, each.actions) and each != final_destination);
		if Act = "goOut"{
			final_destination <- one_of(where(FluxGen, each.location != location));
			arrivee <- any_location_in(final_destination);
		} else {
			final_destination <- one_of(where(possibleEntity, each.fNeed = (possibleEntity max_of each.fNeed)));
			arrivee <- any_location_in(final_destination);
			ask final_destination as environnement_entity {
				do update;
			}
		}
	}
	
	aspect simple {
		draw sphere(1) color: #pink;
	}	
}