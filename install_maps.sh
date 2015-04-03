#!/bin/bash

if [[ ! -f configvars ]]; then
   echo "Please copy the file 'configvars.sample' to 'configvar' and change"
   echo "the variables as necessary before proceeding with the installation."
   exit 1
fi

carto_bin=$(which carto)
if [[ ! -f "${carto_bin}" ]]; then
   echo "'carto' binary could not located in the PATH environment variable."
   echo "In Debian/Ubuntu, you can install it with the command 'sudo apt-get install node-carto'"
fi


. configvars

# Use eval to expand tilde to home directories, or anything else that needs to be expanded,
# and use readlink to get the absolute path of the file/folder
map_installation_path=$(eval readlink -f "${map_installation_path}")
shp_folder_path=$(eval readlink -f "${shp_folder_path}")
mapnik_xml_installation_path=$(eval readlink -f "${mapnik_xml_installation_path}")

if [[ ! -w "${map_installation_path}" ]]; then
   echo "The Map installation directory '${map_installation_path}' does not exist, or the user does not have write access."
   exit 1
fi

if [[ ! -w "${shp_folder_path}" ]]; then
   echo "The shapefiles directory '${shp_folder_path}' does not exist, or the user does not have write access."
   exit 1
fi

if [[ ! -w "${mapnik_xml_installation_path}" ]]; then
   echo "The Mapnik XML directory '${mapnik_xml_installation_path}' does not exist, or the user does not have write access."
   exit 1
fi

if [[ ${#renderd_map_names[@]} -ne ${#maps_to_install[@]} ]]; then
   echo "The arrays 'maps_to_install' and 'renderd_map_names' should be of equal length."
   exit 1
fi

map_installed_at=()
map_name=()

# First download the shapefiles needed by the maps
bash download_shapes.sh

for ((map=0; map<"${#maps_to_install[@]}"; map++)); do
   echo ""
   echo "Processing map ${maps_to_install[$map]}"..
   cd "${maps_to_install[$map]}"
   cp configure.py.sample configure.py
   map_name[$map]=$(cat configure.py | grep 'config\[\"name\"\]' | cut -d\" -f 4)
   sed -i 's|config\["path"\].*|config["path"] = "'${map_installation_path}'"|' configure.py
   sed -i 's|config\["land-high"\].*|config["land-high"] = "'${shp_folder_path}'/land-polygons-split-3857/land_polygons.shp"|' configure.py
   sed -i 's|config\["land-low"\].*|config["land-low"] = "'${shp_folder_path}'/simplified-land-polygons-complete-3857/simplified_land_polygons.shp"|' configure.py
   sed -i 's|config\["ne_places"\].*|config["ne_places"] = "'${shp_folder_path}'/ne_10m_populated_places_simple/ne_10m_populated_places_simple.shp"|' configure.py
   sed -i 's|config\["postgis"\]\["host"\].*|config["postgis"]["host"]     = "'${postgis_host}'"|' configure.py
   sed -i 's|config\["postgis"\]\["port"\].*|config["postgis"]["port"]     = "'${postgis_port}'"|' configure.py
   sed -i 's|config\["postgis"\]\["dbname"\].*|config["postgis"]["dbname"]   = "'${postgis_dbname}'"|' configure.py
   sed -i 's|config\["postgis"\]\["user"\].*|config["postgis"]["user"]     = "'${postgis_user}'"|' configure.py
   # If your password contains the character "|", then change the following sed command to something like this:
   # sed -i 's/config\["postgis"\]\["password"\].*/config["postgis"]["password"] = "'$postgis_password'"/' configure.py
   sed -i 's|config\["postgis"\]\["password"\].*|config["postgis"]["password"] = "'${postgis_password}'"|' configure.py
   map_installed_at[$map]=$(./make.py | awk '{print $3}')
   echo "Map installed at '${map_installed_at[$map]}'"
   rm -rf *.pyc build configure.py
   cd ..
   echo "Building Mapnik XML file '${mapnik_xml_installation_path}/${renderd_map_names[$map]}.xml'."
   ${carto_bin} "${map_installed_at[$map]}/project.mml" > "${mapnik_xml_installation_path}/${renderd_map_names[$map]}.xml"
done

rm sample_renderd.conf
echo ""
echo "A 'sample_renderd.conf' file is generated."
echo "If you choose to use the generated renderd configuration, your:"
for ((i=0; i<${#maps_to_install[@]}; i++)); do
   echo "Map '${maps_to_install[$i]}' will be served at 'http://${host}/${renderd_map_names[$i]}/{zoom}/{x}/{y}.png'"
   
   cat << EOF >> sample_renderd.conf
[${renderd_map_names[$i]}]
URI=/${renderd_map_names[$i]}/
TILEDIR=/var/lib/mod_tile
XML=${mapnik_xml_installation_path}/${renderd_map_names[$i]}.xml
HOST=localhost
TILESIZE=256
MINZOOM=0
MAXZOOM=18

EOF

done

if [[ "${build_leaflet_html}" == "yes" ]]; then
   echo ""
   echo "Building leaflet html file."

   if [[ ! -d "leaflet" ]]; then mkdir leaflet; fi
   cd leaflet
   if [[ ! -f "leaflet.js" ]]; then
	wget http://leaflet-cdn.s3.amazonaws.com/build/leaflet-0.7.3.zip
	unzip leaflet-0.7.3.zip
	rm leaflet-0.7.3.zip
   fi
   if [[ ! -d "plugins" ]]; then mkdir plugins; fi
   cd plugins
   if [[ ! -f "leaflet.zoomdisplay.js" ]]; then
	wget https://raw.githubusercontent.com/azavea/Leaflet.zoomdisplay/master/dist/leaflet.zoomdisplay.js
   fi
   if [[ ! -f "leaflet.zoomdisplay.css" ]]; then
	wget https://raw.githubusercontent.com/azavea/Leaflet.zoomdisplay/master/dist/leaflet.zoomdisplay.css
   fi
   if [[ ! -f "L.Control.Zoomslider.css" ]]; then
	wget https://raw.githubusercontent.com/kartena/Leaflet.zoomslider/master/src/L.Control.Zoomslider.css
   fi
   if [[ ! -f "L.Control.Zoomslider.js" ]]; then
	wget https://raw.githubusercontent.com/kartena/Leaflet.zoomslider/master/src/L.Control.Zoomslider.js
   fi
   sed -i -e 's/width:.*/width: 26px;/' -e 's/height:.*/height: 24px;/' -e 's/left:.*/left: 0px;/' -e 's/font:.*/font: bold 12px\/20px dejavu-sans, Tahoma, Verdana, sans-serif;/' leaflet.zoomdisplay.css
   sed -i ':a;N;$!ba;s/3em;\n}/3em;\n    background-color: #fff;\n}/' leaflet.zoomdisplay.css
   cd ../..

   cat << EOF > map.html
<!doctype html>
<html lang="en">
<head>
   <meta charset="UTF-8">
   <title>Leaflet.zoomdisplay Example</title>
   <link rel="stylesheet" href="leaflet/leaflet.css" />
   <link rel="stylesheet" href="leaflet/plugins/leaflet.zoomdisplay.css" />
   <link rel="stylesheet" href="leaflet/plugins/L.Control.Zoomslider.css" />
   <script type="text/javascript" src="leaflet/leaflet.js"></script>
   <script type="text/javascript" src="leaflet/plugins/leaflet.zoomdisplay.js"></script>
   <script type="text/javascript" src="leaflet/plugins/L.Control.Zoomslider.js"></script>
</head>
<body>
   <div id="map" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"></div>

   <script type="text/javascript">
EOF

   for ((map=0; map<"${#maps_to_install[@]}"; map++)); do
	echo "   var map$map = new L.TileLayer('http://${host}/${renderd_map_names[$map]}/{z}/{x}/{y}.png', {" >> map.html
	echo "                     maxZoom: 18, attribution: 'Locally Served Tiles'});" >> map.html
	echo "" >> map.html
   done

   cat << EOF >> map.html
   var osm = new L.TileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                  maxZoom: 18,
                  attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a>',
                  subdomains: 'abc'
       });

   var ocm = new L.TileLayer('http://{s}.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png', {
                  maxZoom: 18,
                  attribution: 'Map data &copy; <a href="http://opencyclemap.org">OpenCycleMap</a>',
                  subdomains: 'abc'
       });

   var outdoors = new L.TileLayer('http://{s}.tile.opencyclemap.org/outdoors/{z}/{x}/{y}.png', {
                        maxZoom: 18,
                        attribution: 'Map data &copy; <a href="http://opencyclemap.org">OpenCycleMap</a>',
                        subdomains: 'abc'
       });

   var landscape = new L.TileLayer('http://{s}.tile.opencyclemap.org/landscape/{z}/{x}/{y}.png', {
                        maxZoom: 18,
                        attribution: 'Map data &copy; <a href="http://opencyclemap.org">OpenCycleMap</a>',
                        subdomains: 'abc'
       });

   var mapquest_map = new L.TileLayer('http://otile{s}.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpg', {
                           maxzoom:18,
                           attribution: 'Tiles Courtesy of <a href="http://www.mapquest.com/" target="_blank">MapQuest</a> <img src="http://developer.mapquest.com/content/osm/mq_logo.png">',
                           subdomains: '1234'
       });

   var mapquest_sat = new L.TileLayer('http://otile{s}.mqcdn.com/tiles/1.0.0/sat/{z}/{x}/{y}.jpg', {
                           maxzoom:11,
                           attribution: 'Tiles Courtesy of <a href="http://www.mapquest.com/" target="_blank">MapQuest</a> <img src="http://developer.mapquest.com/content/osm/mq_logo.png">',
                           subdomains: '1234'
       });

   var map = new L.Map('map', {
               zoomsliderControl: true,
               zoomControl: false,
               layers: [map1],
               center: [37.9667, 23.7167],
               zoom: 12});
               
   var baseMaps = {
EOF

   for ((map=0; map<"${#maps_to_install[@]}"; map++)); do
	echo "         \"${map_name[$map]}\": map${map}," >> map.html
   done

   cat << EOF >> map.html
         "OpenStreetMap": osm,
         "OpenCycleMap": ocm,
         "Outdoors": outdoors,
         "Landscape": landscape,
         "MapQuest Map": mapquest_map,
         "MapQuest Satellite": mapquest_sat,
   };
   
   L.control.layers(baseMaps).addTo(map);
</script>
</body>
</html>
EOF

   echo "Copy the folder 'leaflet' and the file 'map.html' in a directory served by your webserver."
fi
