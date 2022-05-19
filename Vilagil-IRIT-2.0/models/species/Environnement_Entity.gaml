/**
* Name: EnvironemmentEntity
* Based on the internal empty template. 
* Author: doussin
* Tags: 
*/


model EnvironemmentEntity


import "People.gaml"
/* Insert your model definition here */

species environnement_entity {
	bool available <- true;
	map<string,list> actions <- [];
	int toManyPeople;
	float averageTimeSpent <- 1 #h ;
	int amplitude <- 20;
	list attendance <- [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
	container agents_in_building_current_hour;
	container agents_in_building;
	int usage;
	float fNeed;
	
	map<int,int> building_occupation <- map<int, int>([]);
	
	reflex maj {
//		write self;
		do update;
	}
	
	action youWillSpent {
		float timeIci;
		float amp <- 0.01 * one_of(range(0,amplitude));
		if (current_date.hour + averageTimeSpent) > (current_date.hour + 1 #h){
			if attendance[(current_date.hour +1) mod 24] > attendance[current_date.hour] {
				timeIci <- (flip(0.5))?(averageTimeSpent + averageTimeSpent * amp):(averageTimeSpent - averageTimeSpent * amp);
			} else {
				timeIci <- averageTimeSpent - averageTimeSpent * amp;
			}
		} else {
			timeIci <- (flip(0.5))?(averageTimeSpent + averageTimeSpent * amp):(averageTimeSpent - averageTimeSpent * amp);
		}
		return timeIci;
	}
	
	action update {
		agents_in_building <- remove_duplicates(where(of_generic_species(agents, people), each.final_destination = self));
		usage <- length(agents_in_building);
		if (attendance[current_date.hour] = 0 or toManyPeople = nil){
			fNeed <- 0.0;
		} else if usage <= attendance[current_date.hour] {
			fNeed <- (attendance[current_date.hour] - usage)/attendance[current_date.hour];
		} else {
			fNeed <- - 1 + (toManyPeople - usage)/(toManyPeople - attendance[current_date.hour]);
		}
		if usage >= toManyPeople {
			available <- false;
		} else {
			available <- true;
		}
	}
	
	reflex people_in_building {
		agents_in_building_current_hour <- agents_in_building_current_hour + of_generic_species(agents, people) where(self covers each);
		agents_in_building_current_hour <- remove_duplicates(agents_in_building_current_hour);
	}
	
	reflex compute_agents when:every(#hour){	
		add length(agents_in_building_current_hour) to: building_occupation at: current_date.hour*60 + current_date.minute;
		agents_in_building_current_hour <- [];
	}
}