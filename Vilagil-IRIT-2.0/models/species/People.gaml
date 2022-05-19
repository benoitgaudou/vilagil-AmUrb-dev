/**
* Name: People
* Based on the internal empty template. 
* Author: doussin
* Tags: 
*/


model People

import "../Vilagil_inhabitants2_0.gaml"
import "People.gaml"
import "FluxGenerator.gaml"
import "Environnement_Entity.gaml"
import "Building.gaml"

species people skills: [moving] {
	float speed <- float(one_of(range(2,4))) #km/#h;
	
//	Les actions qui lui sont offertes par l'environnement
	list<string> types;
 
	agent final_destination;
	float timeSpentHere <- 0.0;
	float timeToSpent;
	point arrivee;
	string currentAction;
	bool alreadyLunch <- false;
	bool egoiste <- false;
	map<string,float> lAction <- ["study"::1.0, "goHome"::0.01, "eat"::0.0];
	string pos;
	float champVisuel <- 200.0;
	bool carOwner <- false;
	car gamos;
	
	init {
		pos <- "\"" + self + "\" : [\n";
		do allUpdate;
	}
	
// Ressort de cette action les actions possibles, les batiments permettant l'action et le besoin de chaque batiment
	action perceptible {
		map<string,list<list>> pAction;
		if egoiste = true {
//			ask of_generic_species(agents, environnement_entity) where ((each.actions.keys contains_any types) and (each.available = true) and (distance_to(each, self) < champVisuel)){
//				loop type over: myself.types {
//					loop k over: actions at type {
//						if pAction at k = nil {
//							pAction <- pAction + [k::[[self,fNeed]]];
//						} else {
//							pAction <- pAction + [k::(pAction at k) + [[self, fNeed]]];
//						}
//					}
//				}
//			}
//			do desirable(pAction);
		} else {
			ask of_generic_species(agents, environnement_entity) where ((each.actions.keys contains_any types) and (each.available = true) and (distance_to(each, self) < champVisuel)){
				loop type over: myself.types {
					loop k over: actions at type {
						if pAction at k = nil {
							pAction <- pAction + [k::[[self,fNeed - distance_to(self, myself)/(myself.champVisuel * 3) + (myself.lAction at string(k)/2)]]];
						} else {
							pAction <- pAction + [k::(pAction at k) + [[self, fNeed - distance_to(self, myself)/(myself.champVisuel * 3) + (myself.lAction at string(k)/2)]]];
						}
					}
				}
			}
			if (self.carOwner = true and self.gamos.fNeed != 0.0) {
				pAction <- pAction + ["goHome"::[[self.gamos,self.gamos.fNeed]]];
			} else if (self.carOwner = true) {
				pAction <- pAction + ["goHome"::[[self.gamos,-50]]];
			}
			do desirable(pAction);
		}
	}
	
	action desirable(map<string,list<list>> pAction) {
		if egoiste = false {
			map<string,list<list>> dAction;
			loop k over: pAction.keys {
					dAction <- dAction + [k::(pAction at k)] ;
			}
			do utile(dAction);
		} else {
			return [lAction index_of(lAction where (index_of(lAction, each) in (lAction.keys where in(each, pAction.keys))) with_max_of each),(pAction at (lAction index_of(lAction where (index_of(lAction, each) in (lAction.keys where in(each, pAction.keys))) with_max_of each)))[0][0]];
		}
	}
	
	action utile(map<string,list<list>> dAction) {
		map<string,list> uAction;
		loop k over: dAction.keys {
			list mostNeed <- (dAction at k) with_max_of float(each at 1);
			mostNeed <- [(mostNeed at 0), float(mostNeed at 1)];
			uAction <- uAction + [string(k)::mostNeed];
		}
		return [index_of(uAction, uAction with_max_of float(each at 1)), (uAction with_max_of float(each at 1))[0]];
	}
	
	action perceptionDecision{
		list choix <- perceptible();
		currentAction <- choix[0];
		final_destination <- choix[1];
		arrivee <- any_point_in(final_destination);
		if final_destination = nil {
			if carOwner {
				final_destination <- gamos;
			} else {
				write "ntm";
//				final_destination <- one_of(FluxGen);
			}
			arrivee <- any_point_in(final_destination);
			currentAction <- "goHome";
		}
		ask final_destination as environnement_entity{
			myself.timeToSpent <- float(youWillSpent());
			do update;
		}
	}
	
	reflex timeSpentInActivity when: location = arrivee  {
//		geometry crsPos <- CRS_transform(self.location, crs(shape_file("../../includes/Vilagil/building.shp")));
//		pos <- pos + "{\n	\"heure\" : " + current_date.hour + ",\n 	\"minute\" : " + current_date.minute +",\n	\"x\" : " + (crsPos as point).x + ",\n	\"y\" : " + (crsPos as point).y + "\n}\n],";
		if timeSpentHere > timeToSpent {
			if (currentAction = "eat"){
				lAction <- lAction + ["eat"::0];
				alreadyLunch <- true;
			}
			if final_destination = gamos {
				ask gamos{
					do vroom;
				}
				do homeSweetHome;
			}
			if final_destination is busStop {
				do homeSweetHome;
			}
			if final_destination is FluxGen  {
				do homeSweetHome;
			}
			do perceptionDecision;
			timeSpentHere <- 0.0;
		} else {
			timeSpentHere <- timeSpentHere + step;
		}
//		if final_destination in bicycle  {
//			ask final_destination as bicycle{
//				do vroom;
//			}
//			do homeSweetHome;
//		}
	}
	
	action homeSweetHome  {
//		save pos to:"resultats/positionPietons.json" type:"text" rewrite: false;
		do die;
	}
	
	reflex move when: location != arrivee {
		do goto on:the_graph target:arrivee;
	}
	
	reflex helpMeStepBroIMStuck when: current_edge = nil {
		do die;
	}
	
	action updateEatDesire {
		if alreadyLunch = false {
			lAction <- lAction + ["eat"::exp((-1)*((current_date.hour + current_date.minute/60 - 12.5)^2)) with_precision 3];
		}
	}
	
	action allUpdate virtual: true;
	
//	reflex upPos {
//		geometry crsPos <- CRS_transform(self.location, "EPSG:6326");
////		write crsPos;
////		write self.location;
//		pos <- pos + "{\n	\"heure\" : " + current_date.hour + ",\n 	\"minute\" : " + current_date.minute +",\n	\"x\" : " + (crsPos as point).x + ",\n	\"y\" : " + (crsPos as point).y + "\n},";
//	}
	
	aspect simple {
		draw sphere(1) color: #pink;
	}
}

species student parent: people {
	map<string,float> lAction <- ["study"::1.0, "goHome"::0.1, "eat"::0.0];
	list<string> types <- ["student"];
	map<string, rgb> activityColor <- ["study"::#bold, "goHome"::#gold, "eat"::#chocolate];
	
	action updateStudyDesire {
		if alreadyLunch = false {
			lAction <- lAction + ["study"::(exp((-1/3)*((current_date.hour + current_date.minute/60 - 9)^2)) + exp((-1/3)*((current_date.hour + current_date.minute/60 - 15.5)^2)) ) with_precision 3];
		}
	}
	
	action allUpdate {
		do updateEatDesire;
		do updateStudyDesire;
	}
	
	reflex update {
		do allUpdate;
	}
	
	aspect simple {
		draw sphere(1) color: (activityColor at currentAction);
	}
}

species professor parent: people {
	map<string,float> lAction <- ["work"::1.0, "goHome"::0.1, "eat"::0.0];
	
	action allUpdate {
		do updateEatDesire;
		do updateStudyDesire;
	}
	
	action updateStudyDesire {
		if alreadyLunch = false {
			lAction <- lAction + ["work"::(exp((-1/3)*((current_date.hour + current_date.minute/60 - 9)^2)) + exp((-1/3)*((current_date.hour + current_date.minute/60 - 15.5)^2)) )with_precision 3];
		}
	}
	
	reflex update {
		do allUpdate;
	}
	
	aspect simple {
		draw sphere(1) color: #purple;
	}
}