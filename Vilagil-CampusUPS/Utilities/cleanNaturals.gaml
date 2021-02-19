/**
* Name: cleanNaturals
* Based on the internal empty template. 
* Author: benoitgaudou
* Tags: 
*/


model cleanNaturals

global {

	shape_file naturals0_shape_file <- shape_file("../includes/from_OSM/naturals.shp");
	geometry shape <- envelope(naturals0_shape_file);

	init {
		create natural from: naturals0_shape_file;
		
		save natural where (each.type = "water") type: "shp" to: "../includes/waters.shp";
	}

}

species natural {
	string type;
	aspect default {
		draw shape color: (type = "water") ? #blue : #red;
	}
}



experiment name type: gui {

	output {
		display map {
			species natural;
		}
	}
}