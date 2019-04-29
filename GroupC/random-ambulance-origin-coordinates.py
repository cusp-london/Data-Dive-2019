# Random ambulance origin points to test ambulance selection policy

# Given an incident scene point (aka destination), returns a random set of ambulances available 
# and their coordinates (potential activation points, aka, origins) 
# by randomly sampling points at given radius from the scene


import random
import math

def random_point_at_disk(radius):
  theta = random.random() * 2 * 3.14
  return radius * math.cos(theta), radius * math.sin(theta)

EarthRadius = 6371 # km
OneDegree = EarthRadius * 2 * 3.14 / 360 * 1000 # 1 degree latitude in meters

def random_location(lat, lon, radius):
  dx, dy = random_point_at_disk(radius)
  random_lat = lat + dy / OneDegree
  random_lon = lon + dx / ( OneDegree * math.cos(lat * 3.14 / 180) )
  return round(random_lat, 3), round(random_lon, 3)


print 'OUTSKIRTS:'

print 51.320, -0.055, ' incident location'
for i in range(10):
  print random_location(51.320, -0.055, 5000)

print 51.402, -0.361, ' incident location'
for i in range(10):
  print random_location(51.402, -0.361, 5000)

print 51.668, -0.281, ' incident location'
for i in range(10):
  print random_location(51.668, -0.281, 5000)

print 51.519, -0.184, ' incident location'
for i in range(10):
  print random_location(51.519, -0.184, 5000)


print 'INTERIOR:'

print 51.515, -0.130, ' incident location'
for i in range(10):
  print random_location(51.515, -0.130, 5000)

print 51.524, -0.087, ' incident location'
for i in range(10):
  print random_location(51.524, -0.087, 5000)

print 51.503, -0.103, ' incident location'
for i in range(10):
  print random_location(51.503, -0.103, 5000)

print 51.537, -0.142, ' incident location'
for i in range(10):
  print random_location(51.537, -0.142, 5000)

print 51.490, -0.058, ' incident location'
for i in range(10):
  print random_location(51.490, -0.058, 5000)



