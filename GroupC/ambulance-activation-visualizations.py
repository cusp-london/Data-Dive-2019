from geopy.geocoders import Nominatim
import geopandas as gpd
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import re
from shapely.geometry import Point
import time
%matplotlib inline


# Activation points visualisation
# ===================================================================================== 

# Read in cleaned files Files And Plot activation points
london = gpd.read_file("LSOA_IMD2015.shp")

# High Response time
harrow = london.query('lsoa11cd == "E01002147"')
southwark = london.query('lsoa11cd == "E01004021"')
bexley = london.query('lsoa11cd == "E01000467"')

# Mid response times
islington = london.query('lsoa11cd == "E01002788"')
newton = london.query('lsoa11cd == "E01003566"')

# Low response times
ealing = london.query('lsoa11cd == "E01001253"')
merton = london.query('lsoa11cd == "E01003446"')

lsoas = ["harrow", "southwark", "bexley", "islington", "newton", "ealing", "merton"]
ambulancePoints = [harrow, southwark, bexley, islington, newton, ealing, merton]

# Prints a series of maps showing a Specific LSOA with the surrounding ambulances for it.
for i in range(len(lsoas)):
    print(lsoas[i])
    # Read in cleaned file from R script
    lsoa = pd.read_csv("lsoas[i] + ".csv") 
    lsoa["geometry"] = [Point(xy) for xy in zip(lsoa["lon_activation"], lsoa["lat_activation"])]
    lsoaloc = gpd.GeoDataFrame(lsoa, crs = {'init':'epsg:4326'})
    lsoaloc = lsoaloc.to_crs(epsg = 27700)
    f, ax = plt.subplots(1, figsize=(15, 15))
    ax.set_axis_off()


    lon = london.plot(ax=ax, linewidth=0.1, edgecolor='black', color="white")
    lon.set_xlim(500000, 570000)
    lon.set_ylim(153000, 203000)
    # gdpstation.plot(markersize=30, categorical=True, legend=True, ax=ax)
    ambulancePoints[i].plot(ax=ax, linewidth=0.1, edgecolor='black', color="red")
    lsoaloc.plot(markersize=20, categorical=True, legend=True, ax=ax)
    plt.title("Map Showing Ambulance Locations from LSOA: " + lsoas[i])
    plt.show()
                       
                       
                       
# Same thing for Wards
wards = gpd.read_file("LondonWardsNew.shp")

                       
# interior high high
college = wards.query('WD11CDO == "00BEGG"')

# interior low low
northcote = wards.query('WD11CDO == "00BJGJ"')

# Exterior high high
darwin = wards.query('WD11CDO == "00AFGQ"')
upminster = wards.query('WD11CDO == "00ARGW"')
                       
                      
wards = ["00BEGG", "00BJGJ", "00AFGQ", "00ARGW"]
ambulancePointsWards = [college, northcote, darwin, upminster]
wardNames = ["College", "Northcote", "Darwin", "Upminster"]
                       
# Prints a series of maps showing a Specific WARDS with the surrounding ambulances for it.                       
for i in range(len(wards)):
    print(wards[i])
    # Read in cleaned file from R script
    ward = pd.read_csv("wards[i] + ".csv")
    ward["geometry"] = [Point(xy) for xy in zip(ward["lon_activation"], ward["lat_activation"])]
    wardloc = gpd.GeoDataFrame(ward, crs = {'init':'epsg:4326'})
    wardloc = wardloc.to_crs(epsg = 27700)
    f, ax = plt.subplots(1, figsize=(15, 15))
    ax.set_axis_off()


    lon = london.plot(ax=ax, linewidth=0.1, edgecolor='black', color="white")
    lon.set_xlim(500000, 570000)
    lon.set_ylim(153000, 203000)
    # gdpstation.plot(markersize=30, categorical=True, legend=True, ax=ax)
    ambulancePointsWards[i].plot(ax=ax, linewidth=0.1, edgecolor='black', color="red", legend = True)
    wardloc.plot(markersize=20, categorical=True, legend=True, ax=ax)
    plt.title("Activation Points for Instances within Ward: " + " " + wardNames[i] + " (" + wards[i] + ")")
    plt.savefig(wards[i] + ".png")
    plt.show()
                       
                       
                       
                       
# Geocoding Stations
# =====================================================================================                       
geolocator = Nominatim()
workplace_location = pd.read_csv("workplace location table.csv", na_values = "NULL")
                       
#
lon = []
lat = []
x = ""
geocode = RateLimiter(geolocator.geocode, min_delay_seconds=1)

for i in workplace_location["locationaddress"]:
    time.sleep(1)
    if "Station " in str(i) or "Service " in str(i):
        if "Station " in str(i):
            x = i.split("Station ", 1)[1]
        if "Service " in str(i): 
            x = i.split("Service ", 1)[1]
    else:
        x = str(i)
    
    print(x)
    location = geolocator.geocode(str(x), exactly_one=True)
    #print(location)
    if location is not None:
        lon.append(location.longitude)
        lat.append(location.latitude)
    else:
        lon.append("NULL")
        lat.append("NULL")                       
                       
workplace_location["longitude"] = lon
workplace_location["latitude"] = lat                       
workplace_location.to_csv("workplace_location.csv")
                       
# Visualise Station and Hospitals                        
hosp = pd.read_csv("Hosp.csv")                       
hosp["geometry"] = [Point(xy) for xy in zip(hosp["Longitude"], hosp["Latitude"])]                       
hosploc = gpd.GeoDataFrame(hosp, crs = {'init':'epsg:4326'})                       

# Correct crs                       
london = london.to_crs(epsg = 27700)
hosploc = hosploc.to_crs(epsg = 27700)                       

# Plot Map                       
f, ax = plt.subplots(1, figsize=(15, 15))
ax.set_axis_off()


lon = london.plot(ax=ax, linewidth=0.1, edgecolor='black', color="white")
lon.set_xlim(500000, 570000)
lon.set_ylim(153000, 203000)
hosploc.plot(markersize=30, categorical=True, legend=True, ax=ax)
gdpstation.plot(markersize=30, categorical=True, legend=True, ax=ax)
plt.title("Map Showing the Locations of Hospitals (Blue) and Ambulance Stations (Orange)")
plt.savefig('hospitalsAndStations.png')
                       
                       
                       
                       
                       