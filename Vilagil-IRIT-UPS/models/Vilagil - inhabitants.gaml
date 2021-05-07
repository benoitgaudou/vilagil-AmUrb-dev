/**
* Name: Vilagilinhabitants
* Based on the internal empty template. 
* Author: benoitgaudou
* Tags: 
*/


model Vilagilinhabitants

import "Vilagil.gaml"

global {
	
	int nb_people_per_flat  <- 100;
	bool with_congestion <- false;
	
	float step <- 10 #mn;
	date starting_date <- date("05 23 20","HH mm ss");
	int min_work_start <- 6;
	int max_work_start <- 8;
	int min_work_end <- 16; 
	int max_work_end <- 20; 
	int min_eat_start <- 11;
	int max_eat_start <- 13;
	int lunch_duration <- 1; 

	float min_speed <- 1.0 #km / #h;
	float max_speed <- 5.0 #km / #h; 
	graph the_graph;
	
	list<building> residential_buildings;
	list<building> working_places;
	list<building> eating_places;

	// Indicators
	int nb_people function: length(people);	
	int people_on_the_road function: (people count (each.the_target != nil) ) ;
	float taux_people_on_the_road function: (people count (each.the_target != nil) ) / nb_people;
		
	init {
		do init_env;
		residential_buildings <- building where (each.type="residential");
		working_places <- building where (each.type="university");
		eating_places <- building where (each.type="canteen");
		
		loop residence over: residential_buildings {
			do create_people(nb_people_per_flat  * residence.flats, residence);		
		}
	}
	
	reflex create_congestions when: with_congestion {
		ask roadSimple {
			list<people> vehicles_on_road <- people at_distance 1;
			do update_speed_coeff(length(vehicles_on_road));
		}
		
		map<float, float> road_weights <- roadSimple as_map (each::(each.shape.perimeter / each.speed_coeff));
		the_graph <- the_graph with_weights road_weights;
	}	
	
	
	action create_people(int nb, building res) {
		create people number: nb {
			speed <- rnd(min_speed, max_speed);
			start_work <- rnd (min_work_start, max_work_start);
			end_work <- rnd(min_work_end, max_work_end);
			start_eat <-  rnd(min_eat_start, max_eat_start);
			objective <- "resting";
								
			home <- res;
			workplace <- one_of(working_places);
			canteen <- one_of(eating_places);
			location <- any_location_in (home);
		}		
	}

	action destroy_people(int nb, building res) {
		ask nb among (people where (each.home = res)) {
			do die;
		}
	}	
	
	// @Override
	action add_flats_effects(int n, building res) {
		if(n > 0) {
			do create_people(n  * nb_people_per_flat, res);			
		} else {
			do destroy_people( -n  * nb_people_per_flat, res);
		}
	}
	
	// @Override
	action add_building_effects(building res) {
		do create_people(nb_people_per_flat, res);					
	}
}

species people skills: [moving] {
	rgb color <- #yellow ;
	building home;
	building workplace;
	building canteen;
	
	int start_work ;
	int end_work  ;
	int start_eat;
	int end_eat;
	string objective;
	point the_target <- nil ;
		
	reflex time_to_work when: current_date.hour = start_work and objective = "resting"{
		objective <- "working" ;
		the_target <- any_location_in (workplace);
	}
	
	reflex time_to_canteen when: current_date.hour = start_eat and objective = "working"{
		objective <- "eating" ;
		the_target <- any_location_in (canteen);
	}	

	reflex time_to_work_2 when: current_date.hour = (start_eat +1) and objective = "eating"{
		objective <- "working" ;
		the_target <- any_location_in (workplace);
	}		
		
	reflex time_to_go_home when: current_date.hour = end_work and objective = "working"{
		objective <- "resting" ;
		the_target <- any_location_in (home); 
	} 
	 
	reflex move when: the_target != nil {
		do goto target: the_target on: the_graph ; 
		if the_target = location {
			the_target <- nil ;
		}
	}
	
	aspect default {
		draw sphere(10) color: #red ;
	}
	
	aspect simple {
		draw circle(10) color: color border: #black;
	}	
}

experiment interactive parent: "GISdata" {
	parameter "Nombre d'habitant par étage" var: nb_people_per_flat  <- 10;
	parameter "Step duration" var: step <- 1#mn among: [10#mn, 1#mn, 10#s, 1#s];
	parameter "Avec congestion" var: with_congestion ;
	
	output {
		display "main" parent: map {
			species people;
		}
		display "main2D" parent: mapSimple {
			
			graphics 'CasualtyView' {
				draw ""+current_date at: { 0, 50 } font: font("Arial", 24, # bold) color: #white;
			}
			
			species people aspect: simple;	
			
			chart "ind" type: series background: #black axes: #white size: {0.2,0.2} position: {0.8,0} title_visible: false{
				data "on road" value: people_on_the_road color: #white marker: false;
			}		
		}		
	}
}

experiment multi parent: "GISdata" {
	parameter "Number of inhabitant / step" var: nb_people_per_flat  <- 10;
	parameter "Step duration" var: step among: [10#mn, 1#mn, 10#s, 1#s] <- 1#mn;
	parameter "With congestion?" var: with_congestion <-  false;
	
	init {
	//	create simulation with:[nb_people_per_flat::10,with_congestion::true,step::1];
		create simulation with:[nb_people_per_flat::50,with_congestion::false,step::1#mn, color::#blue];
		create simulation with:[nb_people_per_flat::100,with_congestion::false,step::1#mn, color::#red];	
	} 
	
	permanent {
		display d {
			chart "ind" type: series title_visible: false{
				loop s over: simulations {
					data ""+int(s.nb_people_per_flat) value: s.taux_people_on_the_road color: s.color marker: false;				
				}			
			}
		}
	}


	output {

		display "main2D" parent: mapSimple {
			species people aspect: simple;		
		}		
	}
}