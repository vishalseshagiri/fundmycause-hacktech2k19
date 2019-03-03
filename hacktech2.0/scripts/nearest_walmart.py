import requests
import json
from math import cos, asin, sqrt

def h_distance(lat1, lon1, lat2, lon2):
    p = 0.017453292519943295     #Pi/180
    a = 0.5 - cos((lat2 - lat1) * p)/2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2
    return 12742 * asin(sqrt(a)) #2*R*asin...

def nearest_walmart(lat,long):
    api_str = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location='+str(lat)+','+str(long)+'&radius=30000&name=walmartr&key=AIzaSyC2cBWP6AA79xwXmBRzEhvwoMWi9_SIsWA'
    try:
        r = requests.get(api_str)
        data = r.json()
    except:
        print("Connection error.")
        return None

    shortest_dist = float('Inf')
    vicinity = ''
    best_i = 0
    best_latlong = (0,0)
    for i in range(len(data['results'])):
        if('walmart' in data['results'][i]['name'].lower()):
            computed_dist = h_distance(lat,long,data['results'][i]['geometry']['location']['lat'],data['results'][i]['geometry']['location']['lng'])
            if( computed_dist < shortest_dist):
                shortest_dist = computed_dist
                vicinity =  data['results'][i]['vicinity']
                best_i = i
                best_latlong = (data['results'][i]['geometry']['location']['lat'],data['results'][i]['geometry']['location']['lng'])

    return best_latlong,shortest_dist,vicinity

if __name__ == '__main__':
    lat,long = 34.146153, -118.130492
    latlong, dist, address =  nearest_walmart(lat,long)
    print("Nearest Walmart:", latlong, dist, address)