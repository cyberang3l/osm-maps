#!/bin/bash

shp_dir="$1"

if [[ ! -d "$shp_dir"  ]]; then
   mkdir -p "$shp_dir"
fi

download_land_polygons()
{
   echo "Downloading land_polygons..."
   echo ""
   cd "$shp_dir"
   rm -rf land-polygons-split-3857
   wget http://data.openstreetmapdata.com/land-polygons-split-3857.zip
   unzip land-polygons-split-3857.zip
   rm land-polygons-split-3857.zip
   shapeindex land-polygons-split-3857/land_polygons.shp
   cd ..
}

download_simplified_land_polygons()
{
   echo "Downloading simplified_land_polygons..."
   echo ""
   cd "$shp_dir"
   rm -rf simplified-land-polygons-complete-3857
   wget http://data.openstreetmapdata.com/simplified-land-polygons-complete-3857.zip
   unzip simplified-land-polygons-complete-3857.zip
   rm simplified-land-polygons-complete-3857.zip
   shapeindex simplified-land-polygons-complete-3857/simplified_land_polygons.shp
   cd ..
}

download_ne_10m_populated_places_simple()
{
   echo "Downloading ne_10m_populated_places..."
   echo ""
   cd "$shp_dir"
   rm -rf ne_10m_populated_places_simple
   mkdir ne_10m_populated_places_simple
   cd ne_10m_populated_places_simple
   wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_populated_places_simple.zip
   unzip ne_10m_populated_places_simple.zip
   rm ne_10m_populated_places_simple.zip
   shapeindex ne_10m_populated_places_simple.shp
   cd ../..
}

download_ne_10m_populated_places()
{
   echo "Downloading ne_10m_populated_places..."
   echo ""
   cd "$shp_dir"
   rm -rf ne_10m_populated_places
   mkdir ne_10m_populated_places
   cd ne_10m_populated_places
   wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_populated_places.zip
   unzip ne_10m_populated_places.zip
   rm ne_10m_populated_places.zip
   shapeindex ne_10m_populated_places.shp
   cd ../..
}

download_ne_110m_admin_0_boundary_lines_land()
{
   echo "Downloading ne_110m_admin_0_boundary_lines_land..."
   echo ""
   cd "$shp_dir"
   rm -rf ne_110m_admin_0_boundary_lines_land
   mkdir ne_110m_admin_0_boundary_lines_land
   cd ne_110m_admin_0_boundary_lines_land
   wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/ne_110m_admin_0_boundary_lines_land.zip
   unzip ne_110m_admin_0_boundary_lines_land.zip
   rm ne_110m_admin_0_boundary_lines_land.zip
   shapeindex ne_110m_admin_0_boundary_lines_land.shp
   cd ../..
}

download_world_boundaries()
{
   echo "Downloading world_boundaries..."
   echo ""
   cd "$shp_dir"
   rm -rf world_boundaries
   wget http://planet.openstreetmap.org/historical-shapefiles/world_boundaries-spherical.tgz
   tar xvf world_boundaries-spherical.tgz
   rm world_boundaries-spherical.tgz
   # world_boundaries are already indexed, so we do not need to run shapeindex
   cd ..
}


if [[ ! -d "shp" ]]; then
   # If the shapefiles directory does not exist, then download the shapefiles
   mkdir "$shp_dir"
   download_land_polygons
   download_simplified_land_polygons
   download_ne_10m_populated_places_simple
   download_ne_10m_populated_places
   download_ne_110m_admin_0_boundary_lines_land
   download_world_boundaries
else
   # If the shapefiles directory exists, then check if the md5 sum of the shapefiles is correct
   # If it is correct, then index the shapefiles. Otherwise, remove the directory and redownload
   # the corresponding shapefile.

   md5=$(md5sum shp/land-polygons-split-3857/land_polygons.shp | awk '{print $1}')
   if [[ "$md5" == "0c971c09ad145a7df932669af7cabb3f" ]]; then
	echo "'land-polygons-split-3857' exists. Indexing..."
	shapeindex shp/land-polygons-split-3857/land_polygons.shp
   else
	download_land_polygons
   fi

   md5=$(md5sum shp/simplified-land-polygons-complete-3857/simplified_land_polygons.shp | awk '{print $1}')
   if [[ "$md5" == "502ff9abee21cd954f5054b2ab531691" ]]; then
	echo "'simplified-land-polygons-complete-3857' exists. Indexing..."
	shapeindex shp/simplified-land-polygons-complete-3857/simplified_land_polygons.shp
   else
	download_simplified_land_polygons
   fi

   md5=$(md5sum shp/ne_10m_populated_places_simple/ne_10m_populated_places_simple.shp | awk '{print $1}')
   if [[ "$md5" == "07a7e703065d0be1de3ba98c658d5b95" ]]; then
	echo "'ne_10m_populated_places_simple' exists. Indexing..."
	shapeindex shp/ne_10m_populated_places_simple/ne_10m_populated_places_simple.shp
   else
	download_ne_10m_populated_places_simple
   fi
   
   md5=$(md5sum shp/ne_10m_populated_places/ne_10m_populated_places.shp | awk '{print $1}')
   if [[ "$md5" == "af49081e9d6567d8ae83367c6a8ee67d" ]]; then
	echo "'ne_10m_populated_places' exists. Indexing..."
	shapeindex shp/ne_10m_populated_places/ne_10m_populated_places.shp
   else
	download_ne_10m_populated_places
   fi
   
   md5=$(md5sum shp/ne_110m_admin_0_boundary_lines_land/ne_110m_admin_0_boundary_lines_land.shp | awk '{print $1}')
   if [[ "$md5" == "269f37ff349926c8e53ed5913e1dbeaa" ]]; then
	echo "'ne_110m_admin_0_boundary_lines_land' exists. Indexing..."
	shapeindex shp/ne_110m_admin_0_boundary_lines_land/ne_110m_admin_0_boundary_lines_land.shp
   else
	download_ne_110m_admin_0_boundary_lines_land
   fi
   
   md5=$(md5sum shp/world_boundaries/world_boundaries_m.shp | awk '{print $1}')
   if [[ "$md5" == "a90324620154c06821d1b32848825926" ]]; then
	echo "'world_boundaries' exists."
	# world_boundaries are already indexed, so we do not need to run shapeindex
   else
	download_world_boundaries
   fi
fi
