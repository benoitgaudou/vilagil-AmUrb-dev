/**
* Name: Merge2print
* Based on the internal empty template. 
* Author: benoitgaudou
* Tags: 
*/


model Merge2print

/* Insert your model definition here */

global {
	string area <- "campusUT3-IRIT";
	string includes_folder <- "../includes/"+area+"/";
	
	shape_file boundary0_shape_file <- shape_file(includes_folder+"boundary.shp");
	shape_file roads0_shape_file <- shape_file(includes_folder+"roads.shp");
	shape_file buildings0_shape_file <- shape_file(includes_folder+"buildings.shp");
	shape_file waters0_shape_file <- (file_exists(includes_folder+"waters.shp")) ? shape_file(includes_folder+"waters.shp") : nil;

	geometry shape <- envelope(boundary0_shape_file);
	
	float level_height <- 32.0; // #mm
	float road_buffer <- 2.0;
	float road_height <- 0.3;
	float ground_height <- 0.5;
	
	bool use_level_for_height <- true;
	
	init {
		create building from:buildings0_shape_file {
			if (levels > 0) and use_level_for_height {
				height <- levels * level_height;
			} else {
				height <- 3.0;		
			}
		}
		create road from: roads0_shape_file ;
		
		// Road to dig 
		// list<road> road_to_dig <- road;
		list<road> road_to_dig <- road where(each.type = "residential");
		
		loop r over: road_to_dig {
			create building  {
				shape <- (r.shape + road_buffer) inter world.shape ;
				height <- road_height;
			}
		}
		
		if(waters0_shape_file != nil){
			create water from: waters0_shape_file;
			loop w over: water {
				create building {
					shape <- w.shape;
					height <- road_height;
				}
			}	
		}
		
		list<building> true_buildings <- list<building>(building) ;
		
		create building returns: the_one {
			shape <- copy(world.shape);
			height <- 0.5;
		}
		
		ask the_one {
			loop b over:  true_buildings {
				shape <- shape - b.shape;
			}			
		}
	
		save building to: "to_print.shp" type: "shp" attributes: ["height"::height];
	
	}
}

species building {
	int levels;
	float height ;
}
species road {
	string type;
}
species water{}


experiment name type: gui {

	
	// Define parameters here if necessary
	// parameter "My parameter" category: "My parameters" var: one_global_attribute;
	
	// Define attributes, actions, a init section and behaviors if necessary
	// init { }
	
	
	output {
	// Define inspectors, browsers and displays here
	
	// inspect one_or_several_agents;
	//
		display "My display" { 
			species building;
		}

	}
}