/**
* Name: Vilagilinhabitants20
* Based on the internal empty template. 
* Author: doussin
* Tags: 
*/


model Vilagilinhabitants20

/* Insert your model definition here */

import "species/FluxGenerator.gaml"

global {
	float step <- 1 #minutes;
	geometry shape <- envelope(shape_file("../includes/pointsflux/pointsFlux.shp"));
	date starting_date <- date("08 00 00","HH mm ss");
	int sommeOccupation update: building sum_of each.usage;
	int expectedOccupation update: building sum_of each.attendance[current_date.hour];
	
	//TODO : Webservice Connection
}

experiment "Dayli" type: gui {
	
	output
	{
		display map type: opengl
		{
			species building refresh: false;
			species amenity;			
			species greenSpace;
			species road refresh: false;
			species people aspect:simple;
			species FluxGen aspect:simple;
			species car;
			species parkingPlace;
		}

	}

}