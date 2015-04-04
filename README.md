# OSM Maps Collection
A collection of OpenStreetMap maps, for easy installation. You can use these maps either with a TileServer, or load them on TileMill and edit them.

The main script (`install_maps.sh`) will configure the maps, and generate a Mapnik XML file for each one of them, a sample *renderd.conf* and an optional leaflet based
html file that you can add in your web server to browse your maps.

Each map is located under its own folder, with the original README.md file from the source where I downloaded the map.
The only map I created, is the map *osm-bright-contours*, that is a vanilla OSM-Bright map, with contour lines and elevation labels added.

The following steps will build all the maps properly and install them in one go, and the default settings will install the maps
under ~/Documents/Mapbox/projects, so that you can instantly use them with TileMill.

1. Install an OpenStreetMap Tile Server (look at the second/third sections of this readme file for more information).
2. Copy the file `configvars.sample` to a file name `configvars`
3. Edit the necessary paths and database connection settings.
4. Choose if you want to generate a leaflet html file that you can copy
   to your web server and serve your tiles.
5. Run the bash script `install_maps.sh`
6. Copy the generated renderd configuration lines in `renderd.conf` file.
7. Restart renderd and apache webserver (`service renderd restart && service apache2 restart`)

# Install an OpenStreetMap Tile Server

There is already a nice guide showing how to install an OpenStreetMap Tile server located here: https://switch2osm.org/serving-tiles/

Follow this tutorial, and on the "*import map data*" step extract the part of the map you are interested on, from http://extract.bbbike.org/. Choose the format *OSM -> Protocolbuffer (PBF)*.

At this point you should test that you have a working tile server, that is able to serve tiles if you visit `http://ip.of.your.server/osm/0/0/0.png`

# Add Shuttle Radar Topography Mission (SRTM) Elevation (Contour) Data (The Easy Way)

1. Go again to the website http://extract.bbbike.org/ and choose the same part of the map that chose when you installed the tile server. This time, choose the format "*SRTM Europe PBF (25m)*" if your extract is located in Europe, or "*SRTM World PBF (40m)*" if your extract is located anywhere else in the world, and download the file. (Note: [Here](http://download.bbbike.org/osm/planet/srtm/), you can find the SRTM data for the whole planet if you chose to import the planet OSM file.)
2. Add the following lines at the end of the files `/usr/share/osm2pgsql/default.style` and `/usr/share/osm2pgsql/osm2pgsql/default.style`. These lines will force *osm2pgsql* in the next step to generate three additional table columns in the database, that are needed for the SRTM data. (probably you don't need to add the lines to both of the files, but I don't know which is the correct file so I added the lines to both of them and it worked)

     ```
     # Contour lines
     node,way    contour                 text    linear
     way         contour_ext             text    linear
     way         ele                     text    linear
     ```
3. Append the SRTM data into the database with the command `osm2pgsql --append --slim -c 18000 -d gis --number-processes 8 <srtm-data.pbf>`
