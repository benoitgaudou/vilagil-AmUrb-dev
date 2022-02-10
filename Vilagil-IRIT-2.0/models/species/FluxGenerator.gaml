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

global {
	graph the_graph;
	
	init {
		create building from: shape_file("../includes/Vilagil/building.shp");
		create greenSpace from: shape_file("../includes/Vilagil/greenSpace.shp");
		create amenity from:shape_file("../includes/Vilagil/amenity.shp"){
			if type = "parking" {
				create parkingPlace from: to_squares(self.shape, 5);
			}
		}
		create road from: shape_file("../includes/Vilagil/road_cleaned.shp");
		the_graph <- as_edge_graph(road);
		create FluxGen from: shape_file("../includes/pointsflux/pointsFlux.shp");
		ask FluxGen where(each.name = "FluxGen6" or each.name = "FluxGen8"){
			carCreator <- true;
		}
	}
}

species FluxGen parent: environnement_entity{
	bool carCreator <- false;
	list affluencePeople <- [0,0,0,0,0,0,0,50,70,70,50,50,50,100,100,70,50,50,50,0,0,0,0,0];
	list affluenceCar <- [0,0,0,0,0,0,0,4,10,10,5,0,10,10,5,5,5,5,0,0,0,0,0,0];
	int calcAfflu;
	list actions <- ["goOut"];
		
	reflex pop {
		if affluencePeople[current_date.hour]/( 1 #h / step )  < 1 {
			if flip(affluencePeople[current_date.hour]/( 1 #h / step )){
				calcAfflu <- 1;
			}
		} else if flip( (affluencePeople[current_date.hour] mod ( 1 #h / step ))/( 1 #h / step ) ) {
			calcAfflu <- int(floor(affluencePeople[current_date.hour]/( 1 #h / step ))) + 1 ;
		} else {
			calcAfflu <- int(floor(affluencePeople[current_date.hour]/( 1 #h / step )));
		}
		create people number: calcAfflu{
			location <- myself.location;
			do wichActionIWannaDo;
		}
		calcAfflu <- 0;
	}
	
	reflex carPop when:carCreator = true {
		if affluenceCar[current_date.hour]/( 1 #h / step )  < 1 {
			if flip(affluenceCar[current_date.hour]/( 1 #h / step )){
				calcAfflu <- 1;
			}
		} else if flip( (affluenceCar[current_date.hour] mod ( 1 #h / step ))/( 1 #h / step ) ) {
			calcAfflu <- int(floor(affluenceCar[current_date.hour]/( 1 #h / step ))) + 1 ;
		} else {
			calcAfflu <- int(floor(affluenceCar[current_date.hour]/( 1 #h / step )));
		}
		create car number: calcAfflu{
			location <- myself.location;
			do parkMe;
		}
		calcAfflu <- 0;
	}
	
	aspect simple {
		draw circle(6) color: #pink border: #black;
	}	
}

species environnement_entity {
	list actions <- [];
	int toManyPeople;
	float averageTimeSpent <- 1 #h ;
	list attendance <- [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
	container agents_in_building_current_hour;
	int usage;
	float fNeed;
	
	reflex maj {
		do update;
	}
	
	action update {
		if current_date.minute = 0{
			agents_in_building_current_hour <- remove_duplicates(where(people, each.final_destination = self));
			usage <- length(agents_in_building_current_hour);
		} else {
			agents_in_building_current_hour <- agents_in_building_current_hour + where(people, each.final_destination = self);
			usage <- length(remove_duplicates(agents_in_building_current_hour));
		}
		fNeed <- (attendance[current_date.hour] = 0 or usage > attendance[current_date.hour])?0:(sqrt(((usage - attendance[current_date.hour])/attendance[current_date.hour])^2));
	}
}

species road parent:environnement_entity{
	string type;
	string name;
	
	aspect default
	{
		draw shape color: #black;
	}
}

// A changer
species car parent:environnement_entity skills:[moving]{
	float speed <- float(one_of(range(20,40))) #km/#h;
	bool isParked <- false;
	agent cible;
	point arrivee;
	float timeSpentHere <- 0.0;
	
	reflex hitTheRoad when: isParked = false {
		do goto on:the_graph target:arrivee;
		if arrivee = location {
			if cible is FluxGen{
				ask people where(each.final_destination = self){
					do wichActionIWannaDo;
				}
				do die;
			}
			if cible is amenity {
				isParked <- true;
				create people number: one_of(range(1,2)){
					location <- myself.location;
					do wichActionIWannaDo;
				}
			}
		}
	}
	
	reflex timeToGoHome{
		if timeSpentHere > (cible as environnement_entity).averageTimeSpent {
			actions <- ["drive"];
			timeSpentHere <- 0.0;
		} else {
			timeSpentHere <- timeSpentHere + step;
		}
	}
	
	action parkMe {
		cible <- one_of(where(parkingPlace, each.availble = true));
		if cible = nil {
			do vroom;
		} else {
			ask cible as parkingPlace {
				availble <- false;
			}
		}
		arrivee <- cible.location;
	}
	
	action vroom {
		actions <- [];
		cible <- one_of(where(FluxGen, each.carCreator = true));
		arrivee <- cible.location;
		isParked <- false;
		attendance[current_date.hour] <- 0;
		fNeed <- 0.0;
		ask people where(each.final_destination = self){
			do wichActionIWannaDo;
		}
	}
	
	aspect default
	{
		draw rectangle(4,2) color: #red depth: 2;
	}
}

species building parent:environnement_entity{
	int toManyPeople <- 50;
	int flats <- 2;
	string type;
	string name;
	int maxPeopleInside;
	list actions <- ["study"];
	list attendance <- [0,0,0,0,0,0,0,10,20,50,40,40,30,30,30,40,20,10,10,10,0,0,0,0];
	
	aspect default
	{
		draw shape color: #grey depth: (1 + flats) * 6;
	}
}

species amenity parent:environnement_entity{
	string type;
	
	aspect default
	{
		draw shape color: #darkblue;
	}	
}

species parkingPlace parent:environnement_entity {
	bool availble <- true;
	float averageTimeSpent <- one_of([2 #h, 3 #h, 4 #h]);
}

species greenSpace parent:environnement_entity{
	string type;
	int averageTimeSpent <- 7;
	list attendance <- [0,0,0,0,0,0,0,0,0,0,10,10,10,0,0,0,0,0,0,0,0,0,0,0];
	
	aspect default
	{
		draw shape color: #darkgreen depth: 1;
	}	
	
}