from uber_rides.session import Session
from uber_rides.client import UberRidesClient

def get_estimate(start_lat,start_long,end_lat,end_long,ctype = 0):
    try:
        session = Session(server_token='wRWKZDaExBe71f203wEsxzNllWqwU7nwtEQpJfgR')
        client = UberRidesClient(session)
    except:
        print("Session error.")
        return None
    seats = 2
    response = client.get_price_estimates(
        start_latitude=start_lat,
        start_longitude=start_long,
        end_latitude=end_lat,
        end_longitude=end_long,
        seat_count=seats
    )

    estimate = response.json.get('prices')
    try:
        price_estimate = estimate[ctype]['high_estimate']
        time_estimate = estimate[ctype]['duration']
    except:
        price_estimate = estimate[0]['high_estimate']
        time_estimate = estimate[0]['duration']

    return price_estimate, time_estimate

if __name__ == '__main__':
    start_latitude=37.770
    start_longitude=-122.411
    end_latitude=37.791
    end_longitude=-122.405
    ctype = 7
    estimated_price, estimated_time = get_estimate(start_latitude,start_longitude,end_latitude,end_longitude,ctype)
    print("Estimated Price:", estimated_price)
    print("Estimated Time:", estimated_time)
