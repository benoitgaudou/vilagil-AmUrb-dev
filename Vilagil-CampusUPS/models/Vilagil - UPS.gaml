/**
* Name: VilagilUPS
* Based on the internal empty template. 
* Author: benoitgaudou
* Tags: 
*/

model VilagilUPS

import "Vilagil - inhabitants.gaml"

global {
	string area <- "campusUT3";
	string includes_folder <- "../includes/"+area+"/";
	
	image_file satellite_img <- image_file(includes_folder+"satellite.png");
	shape_file boundary_shp <- shape_file(includes_folder+"boundary.shp");
	shape_file roads_shp <- shape_file(includes_folder+"roads.shp");
	shape_file buildings_shp <- shape_file(includes_folder+"buildings.shp");
	shape_file waters_shp <- shape_file(includes_folder+"waters.shp");

	geometry shape <-  envelope(boundary_shp);
	graph the_graph;
//	init {
//		do init_env;
//	}
	
	action init_env {
		create boundary from: boundary_shp;
		create roadSimple from: roads_shp;
		create waterway from: waters_shp;
		create building from: buildings_shp;
		
		the_graph <- as_edge_graph(roadSimple);				
	}
	
	user_command "Nouveau batiment" {
   		create building number: 1 with: [location::#user_location]  {
   			shape <- circle(50#m);
   			flats <- 1;
   			type <- "residential";
 	 		ask world {
 	 			do add_building_effects(myself);	
 	 		}
   		} 
	}
	
	action add_building_effects(building res) virtual: true;
	action add_flats_effects(int nb, building res) virtual: true;
	
}

// highway
species roadSimple {
	string type;
	
	float capacity <- 1 + shape.perimeter/30;
	float speed_coeff <- 1.0 min: 0.1;
	
	action update_speed_coeff(int n_cars_on_road) {
		speed_coeff <- (n_cars_on_road <= capacity) ? 1 : exp(-( 4 *n_cars_on_road)/capacity);
	}
		
	aspect default {
		draw shape + 5 color: #white;
	}
	
	aspect simple {
		draw shape color: (speed_coeff != 1.0)?#red:#white;
	}
}

// waterway
species waterway {
	string type;

	aspect default {
		draw shape color: #blue;
	}
}

species building {
	string type;
	float height;
	int flats;
	int levels;
	rgb color <- #darkgrey;
	
	list<people> agents_in_building_current_hour <- [];
	map<int,int> building_occupation <- map<int, int>([]);
	
	user_command "add 1 étage" action: increase_by_one_flat;
	user_command "add N étage" action: increase_flats;
	user_command "Destroy 1 étage" action: destroy_one_flat;
	user_command "Destroy N étage" action: destroy_flats;
	
	reflex people_in_building {
		agents_in_building_current_hour <- agents_in_building_current_hour + people where(self covers each);
	}
	
	reflex compute_agents when:every(1#hour){	
		agents_in_building_current_hour <- remove_duplicates(agents_in_building_current_hour);
		add length(agents_in_building_current_hour) to: building_occupation at: current_date.hour;
		agents_in_building_current_hour <- [];
	}
	
	action increase_by_one_flat {
		flats  <- flats + 1;
		ask world {
			do add_flats_effects(1,myself);
		}
	}
	
	action increase_flats {
		map answer <- user_input("Nombre d'étages", [enter("Etage","1")]);
		flats  <- flats + int(answer["Etage"]);
		
		ask world {
			do add_flats_effects(int(answer["Etage"]),myself);
		}
	}
	
	action destroy_one_flat {
		flats  <- flats - 1;
		ask world {
			do add_flats_effects(-1,myself);
		}
	}
	
	action destroy_flats {
		map answer <- user_input("Nombre d'étages à détruire", [enter("Etage","1")]);
		flats  <- flats - int(answer["Etage"]);
		
		ask world {
			do add_flats_effects(-int(answer["Etage"]),myself);
		}
	}	
	
	aspect default {
		draw shape color: color border: #black depth: (1 + flats) * 6; //3
	}
	
	aspect simple {
		draw shape /*- (shape - 3)*/ color: #grey border: #black ;
	}
}

species boundary {
	aspect default {
		draw shape  color: #red empty: true;
	}
}

experiment GISdata type: gui virtual: true {
	output {
		display "map" type: opengl draw_env: false virtual: true {
			image satellite_img ;//transparency: 0.2;
			
			species waterway;
			species building;
			species roadSimple;
			species boundary;		
		}
		
		display mapSimple type: java2D draw_env: false background: #black virtual: true{
			species building aspect: simple;
			species roadSimple aspect: simple;
			species waterway;
			
		}		
	}
}