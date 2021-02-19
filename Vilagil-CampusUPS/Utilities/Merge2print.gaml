/**
* Name: Merge2print
* Based on the internal empty template. 
* Author: benoitgaudou
* Tags: 
*/


model Merge2print

/* Insert your model definition here */

global {

	shape_file buildings0_shape_file <- shape_file("../includes/buildings.shp");
	shape_file roads0_shape_file <- shape_file("../includes/roads.shp");
	shape_file boundary0_shape_file <- shape_file("../includes/boundary.shp");
	shape_file waters0_shape_file <- shape_file("../includes/waters.shp");

	geometry shape <- envelope(boundary0_shape_file);
	
	init {
		create building from:buildings0_shape_file {
			height <- 3.0;
		}
		create road from: roads0_shape_file ;
		
		loop r over: road {
			create building {
				shape <- r.shape +2;
				height <- 0.3;
			}
		}
		
		create  water from: waters0_shape_file;
		loop w over: water {
			create building {
				shape <- w.shape;
				height <- 0.3;
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
	float height ;
}
species road {}
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