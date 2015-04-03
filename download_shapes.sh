#!/bin/bash

download_land_polygons()
{
    echo "Downloading land_polygons..."
    echo ""
    cd shp
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
    cd shp
    rm -rf simplified-land-polygons-complete-3857
    wget http://data.openstreetmapdata.com/simplified-land-polygons-complete-3857.zip
    unzip simplified-land-polygons-complete-3857.zip
    rm simplified-land-polygons-complete-3857.zip
    shapeindex simplified-land-polygons-complete-3857/simplified_land_polygons.shp
    cd ..
}

download_ne_10m_populated_places()
{
    echo "Downloading ne_10m_populated_places..."
    echo ""
    cd shp
    rm -rf ne_10m_populated_places_simple
    mkdir ne_10m_populated_places_simple
    cd ne_10m_populated_places_simple
    wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_populated_places_simple.zip
    unzip ne_10m_populated_places_simple.zip
    rm ne_10m_populated_places_simple.zip
    shapeindex ne_10m_populated_places_simple.shp
    cd ../..
}

if [[ ! -d "shp" ]]; then
    # If the shapefiles directory does not exist, then download the shapefiles
    mkdir shp
    download_land_polygons
    download_simplified_land_polygons
    download_ne_10m_populated_places
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
        download_ne_10m_populated_places
    fi
fi
