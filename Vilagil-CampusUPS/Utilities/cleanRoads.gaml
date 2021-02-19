/**
* Name: cleanNaturals
* Based on the internal empty template. 
* Author: benoitgaudou
* Tags: 
*/


model cleanNaturals

global {

	shape_file roads_shape_file <- shape_file("../includes/from_OSM/roads.shp");
	geometry shape <- envelope(roads_shape_file);

	init {
		create road from: roads_shape_file;
		
//		save road where ( (each.type = 'motorway') or (each.type = 'motorway_link') or (each.type = 'tertiary') or 
//			(each.type = 'tertiary_link') or (each.type = 'primary') or (each.type='primary_link') or (each.type = 'residential') /*or (each.type = 'service')*/) 
//			type: "shp" to: "../includes/roads.shp";

		ask road where not ( (each.type = 'motorway') or (each.type = 'motorway_link') or (each.type = 'tertiary') or 
			(each.type = 'tertiary_link') or (each.type = 'primary') or (each.type='primary_link') or (each.type = 'residential') /*or (each.type = 'service')*/) {
				do die;
			}

		//tolerance for reconnecting nodes
		float tolerance <- 3.0 ;
		//if true, split the lines at their intersection
		bool split_lines <- true ;		
		//if true, keep only the main connected components of the network
		bool reduce_to_main_connected_components <- true ;

		//clean data, with the given options
		list<geometry> clean_lines <- clean_network(road collect each.shape,tolerance,split_lines,reduce_to_main_connected_components) ;
		
		ask road {
			do die;
		}
		
		//create road from the clean lines
		create road from: clean_lines returns: roads_to_save;
		
		save roads_to_save type: "shp" to: "../includes/roads.shp";

	}

}

species road {
	string type;
	aspect default {
		draw shape color: ( (type = 'motorway') or (type = 'motorway_link') or (type = 'tertiary') or 
			(type = 'tertiary_link') or (type = 'primary') or (type='primary_link') or (type = 'residential') /*or (type = 'service')*/
		) ? #blue : #red;
	}
}



experiment name type: gui {

	output {
		display map {
			species road;
		}
	}
}