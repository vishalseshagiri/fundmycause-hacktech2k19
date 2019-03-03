import requests
import json
import ebaysdk
import datetime
from ebaysdk.exception import ConnectionError
from ebaysdk.finding import Connection
from ebaysdk.trading import Connection as Trading
from flask import (
    Flask,
    request as f_request,
    render_template,
    jsonify
)
from optparse import OptionParser
from dotenv import load_dotenv
import os
import googlemaps
from google.cloud import speech_v1p1beta1 as speech
from scripts import nearest_walmart
from scripts import uber_estimate 
from scripts import walmart_spider
import subprocess

# from scripts.nearest_walmart import (
#     h_distance,
#     nearest_walmart
# )
# from scripts.uber_estimate import get_estimate
# from scripts.walmart_spider import mainf

load_dotenv(verbose=True)

creds = {
    'type':os.getenv('acc_type'),
    'project_id':os.getenv('project_id'),
    'private_key_id':os.getenv('private_key_id'),
    'private_key':os.getenv('private_key'),
    'client_email':os.getenv('client_email'),
    'client_id':os.getenv('client_id'),
    'auth_uri':os.getenv('auth_uri'),
    'token_uri':os.getenv('token_uri'),
    'auth_provider_x509_cert_url':os.getenv('auth_provider_x509_cert_url'),
    'client_x509_cert_url':os.getenv('client_x509_cert_url')
}

def add_shipping_cost(x):
    current_price = float(x['sellingStatus']['convertedCurrentPrice']['value'])
    if x['shippingInfo'].get('shippingServiceCost'):
        shipping_cost = float(x['shippingInfo']['shippingServiceCost']['value'])
    else:
        shipping_cost = 0
    return current_price + shipping_cost

# Create the application instance
app = Flask(__name__)

# Create the URL route in out application  for "/"
@app.route('/')
def home():
    """
    """
    return jsonify(msg="Dummy request succesful",
    status="200")

@app.route('/ebay/find')
def find_items_on_ebay():
    api = Connection(appid='Balasubr-hacktech-PRD-916e5579d-aa3f3d9b', config_file=None)
    n_items = int(f_request.args.get('n_items'))
    response = api.execute('findItemsAdvanced', {
        'keywords': f_request.args.get('item'),
        'outputSelector': 'SellerInfo',
        'itemFilter': [
            {
                'name': 'TopRatedSellerOnly',
                'value': 'true'
            }
        ]
    })
    #response = api.execute('GetCharities', {'Query': 'food'})
    assert(response.reply.ack == 'Success')
    assert(type(response.reply.timestamp) == datetime.datetime)
    assert(type(response.reply.searchResult.item) == list)

    item = response.reply.searchResult.item[0]
    assert(type(item.listingInfo.endTime) == datetime.datetime)
    assert(type(response.dict()) == dict)
    result = response.dict()['searchResult']['item'][:10]
    result = sorted(response.dict()['searchResult']['item'][:n_items], key = lambda x: add_shipping_cost(x))
    # print(result)
    return jsonify(result)

@app.route('/ebay/voice2text')
def voice2text():

    client = speech.SpeechClient(
        credentials = creds
    )
    speech_file = f_request.args.get('file')
    with open('./data/{}'.format(speech_file), 'rb') as audio_file:
        content = audio_file.read()

    print(len(content))
    response = ""

    try:
        audio = speech.types.RecognitionAudio(content=content)

        config = speech.types.RecognitionConfig(
            encoding=speech.enums.RecognitionConfig.AudioEncoding.LINEAR16,
            #sample_rate_hertz=16000,
            language_code='en-US',
            audio_channel_count=2,
            enable_separate_recognition_per_channel=True)

        print(type(audio))

        response = client.recognize(config, audio)
        print(dir(response))
        for i, result in enumerate(response.results):
            alternative = result.alternatives[0]
            print('-' * 20)
            print('First alternative of result {}'.format(i))
            print(u'Transcript: {}'.format(alternative.transcript))
            print(u'Channel Tag: {}'.format(result.channel_tag))

    except Exception as e:
        print(e)

    if not response:
        response = {} 

    return jsonify(response)

@app.route('/ebay/vs')
def vs(current_location="2717, Orchard Ave, LA, CA, 90007"):
    product_string = f_request.args.get('product')
    client = googlemaps.Client(os.getenv('map_key'))
    loc = client.geocode(current_location)
    #try:
    # ebay
    latlng = loc[0]['geometry']['location']
    query_params = {'item': product_string, 'n_items': 1}
    ebay_object = requests.get('http://localhost:5000/ebay/find', params=query_params)
    # print(ebay_object.json()[0])
    ebay_cost = add_shipping_cost(ebay_object.json()[0])

    # Walmart + Uber 
    # print(ebay_cost)
    print(latlng)
    wal_latlong, wal_dist, wal_address =  nearest_walmart.nearest_walmart(latlng['lat'], latlng['lng'])
    print(wal_latlong)
    uber_price, _ = uber_estimate.get_estimate(latlng['lat'], latlng['lng'], wal_latlong[0], wal_latlong[1])
    print(product_string)
    # image, wal_price = walmart_spider.mainf(product_string)
    if os.path.isfile('wal_data.json'):
        os.remove('wal_data.json')
    subprocess.check_output('python ./scripts/walmart_spider.py {}'.format(product_string.replace(" ", "%20")), shell=True)
    with open('wal_data.json', 'r') as file:
        wal_obj = json.load(file)
    # print(wal_price)
    #print(wal_obj)
    wal_price = wal_obj[0]['wprice']
    wal_obj[0]['address'] = wal_address
    wal_obj[0]['uber_price'] = uber_price
    total_price = float(wal_price) + (uber_price * 2)
    result = {
        'ebay_better': 1 if total_price > ebay_cost else 0,
        'walmart_object': wal_obj,
        # 'walmart_object': {
        #     'address':wal_address,
        #     'image':image,
        #     'price':wal_price
        # },
        'ebay_object': ebay_object.json()[0]
    }
    # print(result)

    return jsonify(result)

    #except Exception as e:
    #    print("Current location not found : {}".format(e))

#    return jsonify({})

if __name__=="__main__":
    app.run(debug=True)