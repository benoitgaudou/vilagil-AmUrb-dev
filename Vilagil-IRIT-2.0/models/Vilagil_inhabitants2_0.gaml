/**
* Name: Vilagilinhabitants20
* Based on the internal empty template. 
* Author: doussin
* Tags: 
*/


model Vilagilinhabitants20

/* Insert your model definition here */

import "species/FluxGenerator.gaml"

global skills: [network]{
	// Network configuration //
	// MQTT Broker adress //
	string mqtt_broker <- "localhost";
	string sender_name <- "Simple Traffic";
	
	float step <- 15 #minutes;
	geometry shape <- envelope(shape_file("../includes/pointsflux/pointsFlux.shp"));
	date starting_date <- date("08 00 00","HH mm ss");
	
	// Data
	int sommeOccupation update: building sum_of each.usage;
	int expectedOccupation update: building sum_of each.attendance[current_date.hour];
	int maxOccupation update: building sum_of each.toManyPeople;
	int ppStudying update: where(student, each.currentAction = "study") sum_of 1;
	int ppGoHome update: where(student, each.currentAction = "goHome") sum_of 1;
	int ppEating update: where(student, each.currentAction = "eat") sum_of 1;
	int parkedcar update: where(car, each.isParked = true) sum_of 1;
	int carParked update: sum_of(car, 1);
	
	float pas <- float(eval_gaml('1#hour'));
	
	list sumCriticite <- [];
	graph the_graph;
	graph car_graph;
	float ego <- 0.0;
	list<int> affluTest <- [0,0,0,0,0,0,10,10,10,10,10,10,10,10,10,10,10,10,10,0,0,0,0,0];
	list<int> sumA <-[0,0,0,0,0,0,10,10,10,10,10,10,10,10,10,10,10,10,10,0,0,0,0,0];
	
	int people_on_the_road function: (of_generic_species(agents, people) where (each.location != each.arrivee) sum_of 1 );
	
	float carPerCent <- 0.1;
	float busPerCent <- 0.05;
	int dayliPeopleInTheHour <- 150;
	int peopleInTheHour <- dayliPeopleInTheHour;
	
	bool allRestau <- false;
	bool oneRestau <- false;
	bool gary1 <- false;
	bool gary2 <- false;
	bool gary3 <- false;
	
	init {
		//init de l'environnement
		create building from: shape_file("../includes/Vilagil/building.shp");
		create busStop from: shape_file("../includes/Vilagil/bus_stop.shp");
		create foodTruck from: shape_file("../includes/Vilagil/food_Truck.shp");
		ask building where (each.name = "building36" or each.name = "building32" or each.name = "building33"){
			do die;
		}
		create greenSpace from: shape_file("../includes/Vilagil/greenSpace.shp");
		create amenity from:shape_file("../includes/Vilagil/amenity.shp"){
			if type = "parking" {
				create parkingPlace from: to_squares(self.shape, 5);
			}
			if type = "bicycle_parking" {
				create bicyclePlace from: to_squares(self.shape, 2);
			}
		}
		create road from: shape_file("../includes/Vilagil/road_cleaned.shp");
		the_graph <- as_edge_graph(road);
		car_graph <- as_edge_graph( where(road, each.type = "residential"));
		create FluxGen from: shape_file("../includes/pointsflux/pointsFlux.shp");
		ask FluxGen where(each.name = "FluxGen5" or each.name = "FluxGen0"){
			busGen <- true;
			freqBus <- 15 #minutes;
			importance <- 0.4;
		}
		
		//Webservice connection
		do connect to: mqtt_broker with_name: sender_name;
		create NetworkingAgent number: 1;
		
		//Différents Scénarios
		if gary1 = true {
			peopleInTheHour <- 400;
		}
		if gary2 = true {
			peopleInTheHour <- 400;
			create building number: 1 {
//				attendance <- [0,0,0,0,0,0,0,0,70,70,70,70,100,70,70,70,70,0,0,0,0,0,0,0];
				shape <- rectangle(50,50);
				location <- one_of(greenSpace where (each.name = "greenSpace4")).location;
			}
		}
		if gary3 = true {
			peopleInTheHour <- 400;
			create building number: 1 {
//				attendance <- [0,0,0,0,0,0,0,0,70,70,70,70,100,70,70,70,70,0,0,0,0,0,0,0];
				shape <- rectangle(50,50);
				location <- one_of(greenSpace where (each.name = "greenSpace4")).location;
			}
			carPerCent <- 0.05;
			busPerCent <- 0.1;
		}
	}
	
	species NetworkingAgent skills:[network]{
		
		init {
			do connect to: mqtt_broker with_name: "mailbox";
			do sendBuilding;
			do sendFluxGen;
			do sendBusUse;
			do sendCarUse;
			do sendWorldCoord;
			do sendParking;
			do sendPeopleByHour;
		}
		
		reflex fetch when:has_more_message(){
			//
			message mess <- fetch_message();
			list content <- split_with(string(mess.contents), ' ');
			write mess;
			
			if 'changeType' in content{
				ask building where(each.name=content[1]){
					actions <- actions + ["student"::[content[2]]] + ["professor"::[content[2]]];
					if content[2] = "study" {
						attendance <- [0,0,0,0,0,0,0,20,30,60,50,40,30,40,50,50,30,20,10,10,0,0,0,0];
					} else if content[2] = "eat" {
						attendance <- [0,0,0,0,0,0,0,0,70,70,70,70,100,70,70,70,70,0,0,0,0,0,0,0];
					}
				}
				do sendBuilding;
			}
			
			if 'changePeopleByHour' in content{
				dayliPeopleInTheHour <- content[1];
//				write busPerCent;
				ask world {
					do fin;
				}
				do sendPeopleByHour;
			}
			
			if 'changeBusUse' in content{
				busPerCent <- float(content[1]);
//				write busPerCent;
				do sendBusUse;
			}
			
			if 'changeCarUse' in content{
				carPerCent <- float(content[1]);
//				write busPerCent;
				do sendCarUse;
			}
			
			if 'changeFreqBus' in content{
				ask FluxGen where(each.name=content[1]){
					freqBus <- float(eval_gaml(content[2]));
				}
				do sendFluxGen;
			}
			
			if 'createBuilding' in content{
				create building number: 1 with: [location::point(int(content[1]),int(content[2]))]{
		   			shape <- rectangle(50,50);
		   		}
		   		do sendBuilding;
			}
		}
		
		reflex toSend {
			do send to:"dynamic/metric/peopleOnTheRoad" contents:people_on_the_road;
		}
		
		action sendBuilding{
			list<string> buildingName;
			loop agt over: building {
				buildingName <- buildingName + agt.name;
				string topic_path <- "static/buildings/type/"+agt.name;
				do send to:topic_path contents:[agt.actions at "student"];
				topic_path <- "static/buildings/location/"+agt.name;
				do send to:topic_path contents:[[string(agt.location.x) + "," + string(agt.location.y)]];
			}
			do send to:"static/buildings/list" contents:buildingName;
		}
		
		action sendFluxGen{
			list<string> fluxName;
			loop agt over: FluxGen {
				fluxName <- fluxName + agt.name;
				string topic_path <- "static/FluxGen/location/"+agt.name;
				do send to:topic_path contents:[[string(agt.location.x) + "," + string(agt.location.y)]];
				topic_path <- "static/FluxGen/busFreq/"+agt.name;
				do send to:topic_path contents:[[string(agt.freqBus)]];
			}
			do send to:"static/FluxGen/list" contents:fluxName;
		}
		
		action sendBusUse {
			do send to:"static/metric/busUse" contents:string(busPerCent);
		}
		
		action sendCarUse {
			do send to:"static/metric/carUse" contents:string(carPerCent);
		}
		
		action sendWorldCoord {
			do send to:"static/metric/worldShape" contents:string(world.shape);
		}
		
		action sendPeopleByHour {
			do send to:"static/metric/peopleByHour" contents:string(peopleInTheHour);
		}
		
		action sendParking {
			list<string> parkName;
			loop agt over: amenity where (each.type = "parking" or each.type = "bycicle_parking") {
				parkName <- parkName + agt.name;
				string topic_path <- "static/parking/type/"+agt.name;
				do send to:topic_path contents:[agt.type];
			}
			do send to:"static/parking/list" contents:parkName;
		}
		
		reflex sendOccupation when: every(#hour){
			loop agt over: amenity where (each.type = "parking" or each.type = "bycicle_parking") {
				string topic_path <- "dynamic/parking/occupation/"+agt.name;
				do send to:topic_path contents:[[string(agt.building_occupation)]];
			}
			loop agt over: building{
				string topic_path <- "dynamic/buildings/occupation/"+agt.name;
				do send to:topic_path contents:[[string(agt.building_occupation)]];
			}
		}
		
	}
	
	reflex changeFreq {
		do fin;
	}
	
	action fin {
		if current_date.hour > 17 or current_date.hour < 6 {
			peopleInTheHour <- 0;
		} else {
			peopleInTheHour <- dayliPeopleInTheHour;
		}
	}
	
	reflex end_of_runs when: (current_date.hour = 19 and current_date.minute = 0){
			save ([sum(affluTest)] + sumCriticite) to:"resultats/resultsEgo.csv" type:"csv" rewrite: false header: false;
     }
     
     reflex upCrit when: current_date.minute = 30{
		sumCriticite <- sumCriticite + (building sum_of each.fNeed);
	}
	
	user_command "Nouveau batiment" {
   		create building number: 1 with: [location::#user_location]{
   			shape <- rectangle(50,50);
   		}
	}
	
}

experiment gary type:gui{
	init {
		create simulation with:[gary1::true];
		create simulation with:[gary2::true];
		create simulation with:[gary3::true];
	}
	
//	permanent{
//		display data {
//			chart "ind" type: series title_visible: false {
//				loop s over: simulations {
//					data s.name value: s.carParked color: s.color;
//				}
//			}
//		}
//	}

	output {
		layout #split;
		display map {
			species building refresh: false;
			species amenity;			
			species greenSpace;
			species road refresh: false;
			species student aspect:simple;
			species FluxGen aspect:simple;
			species professor aspect:simple;
			species bicycle;
			species parkingPlace;
			species bicyclePlace;
			species car;
			species busStop;
			species foodTruck;
			species Bus;
		}
		
		display chart_display refresh: every(10 #cycles) {
            chart "Activity" type: series  x_serie_labels: current_date.hour {
                data "Studying" value: ppStudying color: #green;
                data "Passing" value: ppGoHome color: #red;
                data "ExpectedStudy" value: expectedOccupation color: #purple;
                data "parkedcar" value: parkedcar color:#blue;
            }
        }
	}
}

experiment "Dayli" type: gui {
	parameter CarPerCent var: carPerCent min: 0.0 max: 1.0;
	parameter BusPerCent var: busPerCent min: 0.0 max: 1.0;
	parameter peopleInTheHour var: peopleInTheHour min: 0 max: 600;
	
	init{
	}
	
	output {
		display map type: opengl {
			species building refresh: true;
			species amenity;			
			species greenSpace refresh: true;
			species road refresh: false;
			species student aspect:simple;
			species FluxGen aspect:simple;
			species professor aspect:simple;
			species car;
			species bicycle;
			species parkingPlace;
			species bicyclePlace;
			species busStop;
			species foodTruck;
			species Bus;
		}
		
//		display chart_display refresh: every(10 #cycles) {
//            chart "Activity" type: series  x_serie_labels: current_date.hour {
//                data "Studying" value: ppStudying color: #green;
//                data "Passing" value: ppGoHome color: #red;
//                data "ExpectedStudy" value: expectedOccupation color: #purple;
//                data "parkedcar" value: parkedcar color:#blue;
//            }
//        }
	}
}

experiment many_iteration type: batch repeat: 10 keep_seed: true until: (current_date.hour = 23){
	reflex end_of_runs{
		save (sumCriticite) to:"resultats/results.csv" type:"csv" rewrite: false header: false;
     }
}

experiment exploDiffUtile type: batch repeat: 1 keep_seed: true until: (current_date.hour = 19 and current_date.minute = 1){
	init {
		list<list> toDo <- list_with(40,[]);
		loop k from:0 to: 39{
			list<int> aTest <- affluTest;
			loop i from: 0 to: length (affluTest) - 1{
				aTest[i] <- aTest[i] + k*sumA[i];
			}
			toDo[k] <- list(aTest);
		}
		loop k from: 0 to: 39{
			create simulation with:[affluTest::toDo[k]];
		}

	}
}

