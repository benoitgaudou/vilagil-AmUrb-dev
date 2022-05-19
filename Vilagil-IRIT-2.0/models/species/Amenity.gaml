/**
* Name: Amenity
* Based on the internal empty template. 
* Author: doussin
* Tags: 
*/


model Amenity

import "Environnement_Entity.gaml"

species amenity parent:environnement_entity{
	string type;
	bool availble <- true;
	
	aspect default
	{
		draw shape color: #darkblue;
	}
	
	reflex people_in_building {
		agents_in_building_current_hour <- agents_in_building_current_hour + of_generic_species(agents, car) where(self covers each and each.isParked);
		agents_in_building_current_hour <- remove_duplicates(agents_in_building_current_hour);
	}
	
	reflex compute_agents when:every(#hour){	
		add length(agents_in_building_current_hour) to: building_occupation at: current_date.hour*60 + current_date.minute;
		agents_in_building_current_hour <- [];
	}
}

species parkingPlace parent:environnement_entity {
	bool availble <- true;
	float averageTimeSpent <- one_of([2 #h, 3 #h, 4 #h]);
}

species bicyclePlace parent:environnement_entity {
	bool availble <- true;
	float averageTimeSpent <- one_of([2 #h, 3 #h, 4 #h]);
}