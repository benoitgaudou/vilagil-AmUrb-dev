/**
* Name: OSM file to Agents
* Author:  Patrick Taillandier
* Description: Model which shows how to import a OSM File in GAMA and use it to create Agents. In this model, a filter is done to take only into account the roads 
* and the buildings contained in the file. 
* Tags:  load_file, osm, gis
*/
model simpleOSMLoading


global
{

//map used to filter the object to build from the OSM file according to attributes. for an exhaustive list, see: http://wiki.openstreetmap.org/wiki/Map_Features
	map filtering <- map([
	"highway"::[], //["primary", "secondary", "tertiary", "motorway", "living_street", "residential", "unclassified"], 
	"building"::["yes","university"],
	"amenity"::["parking","bicycle_parking"],
	"landuse"::[]
	]);
	//OSM file to load
//	file<geometry> osmfile;

	//compute the size of the environment from the envelope of the OSM file
//	geometry shape <- envelope(osmfile);
	init
	{
	//possibility to load all of the attibutes of the OSM data: for an exhaustive list, see: http://wiki.openstreetmap.org/wiki/Map_Features
//		create osm_agent from: osmfile with: [
//			highway_str::string(read("highway")), 
//			building_str::string(read("building")), 
//			amenity_str::string(read("amenity")),
//			name_str::string(read("name")),
//			landuse_str::string(read("landuse"))
//		];
//
//		//from the created generic agents, creation of the selected agents
//		ask osm_agent
//		{
////			if (length(shape.points) = 1 and highway_str != nil)
////			{
////				create node_agent with: [shape::shape, type:: highway_str];
////			} else {
//			write landuse_str;
//			if (length(shape.points) != 1 ) {
//				if (highway_str != nil)  {
//					create road from: shape_file("../includes/Vilagil/road_cleaned.shp");
//				} else if (building_str != nil) {
//					create building from: shape_file("../includes/Vilagil/building.shp");
//				} else if (amenity_str != nil) {
//					create amenity from:shape_file("../includes/Vilagil/amenity.shp");
//				} else if (landuse_str  != nil) {
//					create greenSpace from: shape_file("../includes/Vilagil/greenSpace.shp");			
//				}
//
//			}
//			//do the generic agent die
//			do die;
//		}
//	string p <- "../includes/Vilagil/";
//	save building type: shp to: p+"building.shp" attributes: ["type"::type,"name"::name];
//	save road type: shp to: p+"road.shp" attributes: ["type"::type,"name"::name];
//	save amenity type: shp to: p+"amenity.shp" attributes: ["type"::type];
//	save greenSpace type: shp to: p+"greenSpace.shp" attributes: ["type"::type];
	create building from: shape_file("../includes/Vilagil/building.shp");
	create greenSpace from: shape_file("../includes/Vilagil/greenSpace.shp");
	create amenity from:shape_file("../includes/Vilagil/amenity.shp");
	create road from: shape_file("../includes/Vilagil/road_cleaned.shp");
	}

}

species osm_agent
{
	string highway_str;
	string building_str;
	string amenity_str;
	string name_str;
	string landuse_str;
}

species road {
	string type;
	string name;
	
	aspect default
	{
		draw shape color: #black;
	}

}

species node_agent
{
	string type;
	aspect default
	{
		draw square(3) color: # red;
	}
}

species building
{
	string type;
	string name;
	
	aspect default
	{
		draw shape color: #grey;
	}
}

species amenity {
	string type;
	
	aspect default
	{
		draw shape color: #darkblue;
	}	
}

species greenSpace {
	string type;
	
	aspect default
	{
		draw shape color: #darkgreen;
	}	
	
}

experiment "Load OSM" type: gui
{
//	parameter "File:" var: osmfile <- file<geometry> (osm_file("../includes/Vilagil/map_small.osm", filtering));
	output
	{
		display map type: opengl
		{
			species building refresh: false;
			species amenity;			
			species greenSpace;
			species road refresh: false;
			species node_agent refresh: false;
		}

	}

}

//experiment "Load OSM from Internet" type: gui parent: "Load OSM"
//{
//	parameter "File:" var: osmfile <- file<geometry> (osm_file("http://download.geofabrik.de/europe/andorra-latest.osm.pbf", filtering));
//	
//}
