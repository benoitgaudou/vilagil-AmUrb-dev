/**
* Name: Vilagilinhabitants
* Based on the internal empty template. 
* Author: benoitgaudou
* Tags: 
*/


model Vilagilinhabitants

import "Vilagil - UPS.gaml"

global skills: [network]{
	
	// Network configuration //
	// MQTT Broker adress //
	string mqtt_broker <- "localhost";
	string sender_name <- "Simple Traffic";
	
	int nb_people_per_flat  <- 10;
	bool with_congestion <- false;
	
	float step <- 10 #mn;
	date starting_date <- date("05 20 20","HH mm ss");
	int min_work_start <- 6;
	int max_work_start <- 8;
	int min_work_end <- 16; 
	int max_work_end <- 20; 
	float min_speed <- 1.0 #km / #h;
	float max_speed <- 5.0 #km / #h; 
	graph the_graph;
	
	list<building> residential_buildings;
	list<building> workingplaces;

	// Indicators
	int nb_people function: length(people);	
	int people_on_the_road function: (people count (each.the_target != nil) ) ;
	float taux_people_on_the_road function: (people count (each.the_target != nil) ) / nb_people;
		
	init {
		do init_env;
		residential_buildings <- building where (each.type="residential");
		workingplaces <- building - residential_buildings;
		
		do connect to: mqtt_broker with_name: sender_name;
		do sendBuilding;
		
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
			objective <- "resting";
								
			home <- res;
			workplace <- one_of(workingplaces);
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
	
	reflex doTo{
		do sendOnce;
//		if current_date.minute = 0 {
//			
//		}
	}
	
	action sendBuilding{
		loop agt over: building {
			string topic_path <- "static/buildings/"+agt.name+"/shape";
			do send to:topic_path contents:serialize(agt.shape);	
		}
		
	}
	
	reflex sendOccupation when:every(24#hour){
		loop agt over: building {
			string topic_path <- "dynamic/buildings/occupation/"+agt.name;
			string str <- "";
			loop i from: 0 to: 23{
				str <- str + agt.building_occupation[i]+" ";
			} 
			write str;
			do send to:topic_path contents:str;
		}
	}
	
	action sendOnce{
		map people__pos;
		loop agt over: people {
			add (agt.name)::(agt.location) to:people__pos;
		}
		do send to:"dynamic/agent/position" contents:serialize(people__pos);	
		do send to:"dynamic/metric/peopleOnTheRoad" contents:people_on_the_road;
	}
	
	species NetworkingAgent skills:[network]{
		reflex fetch when:has_more_message()
		{	
			message mess <- fetch_message();
			write name + " fecth this message: " + mess.contents;
		}
	}
}

species people skills: [moving] {
	rgb color <- #yellow ;
	building home;
	building workplace;
	
	int start_work ;
	int end_work  ;
	string objective;
	point the_target <- nil ;
		
	reflex time_to_work when: current_date.hour = start_work and objective = "resting"{
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
	parameter "Step duration" var: step among: [10#mn, 1#mn, 10#s, 1#s];
	parameter "Avec congestion" var: with_congestion ;
	
	output {
		display "main" parent: map {
			species people;
		}
		display "main2D" parent: mapSimple {
			
			graphics 'CasualtyView' {
				draw ""+current_date at: { 0, 100 } font: font("Arial", 24, # bold) color: #white;
			}
			
			species people aspect: simple;	
			
			chart "ind" type: series background: #black axes: #white size: {0.3,0.3} position: {0.7,0} title_visible: false{
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
