const lib = require('lib')({token: 'u9JRrvf8NnMajPmDXq3XNNUyX9iYqhKSiQCIH86Lyb2PHslTabzSV_5vo0BZWnlO'});
const Promise = require('bluebird');
var reqProm = require('request-promise');

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * @param {string} sender The phone number that sent the text to be handled
 * @param {string} receiver The StdLib phone number that received the SMS
 * @param {string} message The contents of the SMS
 * @param {string} createdDatetime Datetime when the SMS was sent
 * @returns {any}
 */
module.exports = async (sender , receiver, message, createdDatetime, context) => {
    //message = 'UBER, 43.865980, -79.35769046, 33 Linwood Avenue Scarborough'
    //module.exports = async (sender, receiver, message, createdDatetime, context) => {
  // let result = await lib.messagebird.tel.sms({
  //     originator: '12262860381',
  //     recipient: sender,
  //     body: "pls"
  //   });
  // return result;
  let split = message.split(",");
  split[0] = split[0].replace(/ /g,"");
  if (message.toUpperCase() == 'HELP'){
    let result = await lib.messagebird.tel.sms({
      originator: '12262860381',
      recipient: sender,
      // recipient: '6479936121',
      body: "Text help,<directions/places/weather> for more detailed information"
    });
  }
  if (split[0].toUpperCase() == 'DRIVING' || split[0].toUpperCase() == 'WALKING' || split[0].toUpperCase() == 'TRANSIT' ||
      split[0].toUpperCase() == 'DRIVE' || split[0].toUpperCase() == 'WALK' || split[0].toUpperCase() == 'PUBLIC'){

    if (split[0].toUpperCase() == 'DRIVE')          //Cause Merlin wanted to give me more work
      split[0] = 'driving'
    else if (split[0].toUpperCase() == 'WALK')
      split[0] = 'walking'        //changes app one to the mode used by the server
    else if (split[0].toUpperCase() == 'TRANSIT')
      split[0] = 'transit'

    let apikey = 'AIzaSyDBkFlNkBDZO78HHjofbA9-B91p2hHRFoA'
    let mode = split[0]
    let googleapi = ""
    if (split.length == 3){
      let origin = split[1]
      let destination = split[2]
      googleapi = await 'https://maps.googleapis.com/maps/api/directions/json?key=' + apikey +
                       '&mode=' + mode +
                       '&origin=' + origin +
                       '&destination=' + destination
      googleapi = googleapi.replace(/ /g,"%20")
    }
    else{
      let lat = split[1].replace(/ /g,"")
      let lon = split[2].replace(/ /g,"")
      let destination = split[3]
      googleapi = 'https://maps.googleapis.com/maps/api/directions/json?key=' + apikey +
                       '&mode=' + mode +
                       '&origin=' + lat + "," + lon +
                       '&destination=' + destination
      googleapi = googleapi.replace(/ /g,"%20")
    }

    let res = await reqProm({               //wait for GET request
        url: googleapi
      }).then(function(directions) {        //push response to next
        return directions
      }).then(d =>{                         //where we do stuff with the body
        d = JSON.parse(d)

        let totalD = d.routes[0].legs[0].distance.text
        let totalT = d.routes[0].legs[0].duration.text

        let response = {}
        response['Distance'] = totalD
        response['Duration'] = totalT

        response['Steps'] = []
        for (i = 0; i < d.routes[0].legs[0].steps.length; i++){
          let step = String(i+1) + ") " + String(d.routes[0].legs[0].steps[i].html_instructions)
          step = step.replace(/<\/?[^>]+(>|$)/g, "");
          response.Steps.push(step)
        }
        return response;
      })
    let result = await lib.messagebird.tel.sms({
      originator: '12262860381',
      recipient: sender,
      // recipient: '6479936121',
      body: " "+((JSON.stringify(res,null,2)).slice(1, -1)).replace(/\"/g, "")
    });
    return res
  }
  else if (split[0].toUpperCase() == 'DESCRIPTION'){
    let apikey = 'AIzaSyDBkFlNkBDZO78HHjofbA9-B91p2hHRFoA'
    let keyword = split[1]
    let location = split[2]

    let googlequery = 'https://maps.googleapis.com/maps/api/place/queryautocomplete/json?key=' + apikey +
                      '&input=' + keyword + " in " + location
                      //'&input=' + "McDonalds in Markham"

    googlequery = googlequery.replace(/ /g,"%20")
    console.log(googlequery)

    let query = await reqProm({               //wait for GET request
        url: googlequery
      }).then(function(q) {        //push response to next
        return q
      }).then(place =>{                         //where we do stuff with the body
        place = JSON.parse(place)
        return place.predictions[0].description
      }).then(description => {
        let googleplace = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?key=' + apikey +
                          '&input=' + description
        console.log(description)
        return googleplace
      }).then(googleplace => {
        googleplace = googleplace.replace(/ /g,"%20")
        googleplace = googleplace.replace(/,/g,"")
        console.log(googleplace)
        let theplace = reqProm({               //wait for GET request
            url: googleplace
          }).then(function(p) {        //push response to next
            return p
          }).then(pl =>{                         //where we do stuff with the body
            pl = JSON.parse(pl)
            return pl.predictions[0].place_id
          }).then(placeid => {
            let details = 'https://maps.googleapis.com/maps/api/place/details/json?key=' + apikey +
                          '&placeid=' + placeid
            details = details.replace(/ /g,"%20")
            details = details.replace(/,/g,"")
            let bruhfinally = reqProm({
              url: details
            }).then(function(d){
              return d
            }).then(body => {
              let response = {}
              console.log(body)
              body = JSON.parse(body)
              response["Address"] = ""
              for (i = 0; i < body.result.address_components.length; i++){
                response["Address"] += body.result.address_components[i].short_name + " "
              }
              if (body.result.opening_hours != null){
                if (body.result.opening_hours.open_now == true){
                  response["Open"] = ("Open now")
                }
                else{
                  response["Closed"] = ("Closed now")
                }
              }
              if (body.result.rating != null){
                response["Rating"] = (body.result.rating)
              }
              if (body.result.price_level != null){
                response["PriceLevel"] = (body.result.price_level)
              }
              if (body.result.opening_hours != null){
                response["OpeningHours"] = (body.result.opening_hours.weekday_text)
              }
              return response
            })
            return bruhfinally                //the promise for details
          })
          return theplace                     //the promise for the place
      })
    let result = await lib.messagebird.tel.sms({
      originator: '12262860381',
      recipient: sender,
      // recipient: '6479936121',
      body: " "+((JSON.stringify(query,null,2)).slice(1, -1)).replace(/\"/g, "")
    })
    return query;
  }
  else if (split[0].toUpperCase() == 'WEATHER'){
    let apikey = '70e33d184ea2454e27c8619e319ea040'
    if (split.length == 3){
      let lat = split[1].replace(/ /g,"")
      let lon = split[2].replace(/ /g,"")
      weatherapi = 'http://api.openweathermap.org/data/2.5/weather?units=metric&appid=' + apikey +
                   '&lat=' + lat +
                   '&lon=' + lon
    }
    else {
      let place = split[1].replace(/ /g,"")
      weatherapi = 'http://api.openweathermap.org/data/2.5/weather?units=metric&appid=' + apikey +
                   '&q=' + place
    }
    weatherapi = weatherapi.replace(/ /g,"%20")
    console.log(weatherapi)

    let res = await reqProm({               //wait for GET request
        url: weatherapi
      }).then(function(weather) {        //push response to next
        return weather
      }).then(weather =>{                         //where we do stuff with the body
        weather = JSON.parse(weather)
        response = {}
        response['Location'] = weather.name
        response['Description'] = weather.weather[0].description
        response['Temperature'] = weather.main.temp
        response['High'] = weather.main.temp_max
        response['Low'] = weather.main.temp_min
        response['Wind'] = weather.wind.speed + "km/h"
        console.log(response)
        return response
      })
    let result = await lib.messagebird.tel.sms({
      originator: '12262860381',
      recipient: sender,
      // recipient: '6479936121',
      body: " "+((JSON.stringify(res,null,2)).slice(1, -1)).replace(/\"/g, "")
    });
    return res
  }
  else if (split[0].toUpperCase() == 'UBER'){
    let apikey = 'AIzaSyDBkFlNkBDZO78HHjofbA9-B91p2hHRFoA'
    let uberkey = 'Bearer JA.VUNmGAAAAAAAEgASAAAABwAIAAwAAAAAAAAAEgAAAAAAAAG8AAAAFAAAAAAADgAQAAQAAAAIAAwAAAAOAAAAkAAAABwAAAAEAAAAEAAAAHeztO70nettOqmcb8_yUV5sAAAAMUe0A-AfEF9drpZq4Y1H0mjjXwSNAfYZ4bCvt9gqUVbdYLec2bkJUIwXxqxsMMITwQ7fYvVadOMCpf6CTdJEHRo1bTHBEJFUolwnJHHgE1kDOhzA4JRM4xjhEmy5jL-RmXUpkA0urnoRxm7CDAAAACqJj30wPiacpy0tiSQAAABiMGQ4NTgwMy0zOGEwLTQyYjMtODA2ZS03YTRjZjhlMTk2ZWU'
    let lat = split[1];
    let lon = split[2];
    let dest = split[3];

    let googlequery = 'https://maps.googleapis.com/maps/api/geocode/json?key=' + apikey +
                      '&address=' + dest;

    let query = await reqProm({               //wait for GET request
        url: googlequery
      }).then(function(q) {        //push response to next
        return q
      }).then(place =>{                         //where we do stuff with the body
        place = JSON.parse(place)
        let destlat = place.results[0].geometry.location.lat;
        let destlon = place.results[0].geometry.location.lng;
        let dest = {lat: destlat, lon: destlon};
        return dest;
      });

      console.log(query);
      let uberquery = 'https://sandbox-api.uber.com/v1.2/requests/estimate?'

    let uberEstimate = await reqProm({
      method: 'POST',
      url: uberquery,
      headers:{
          authorization: uberkey
      },
      body: {
        start_latitude: lat,
	      start_longitude:lon,
	      end_latitude: query.lat,
	      end_longitude: query.lon
      },
      json: true
    }).then(function(q){
      let res = {
        cost: q.fare.value,
        fare_id: q.fare.fare_id,
        time: q.trip.duration_estimate,
        distance: q.trip.distance_estimate
      }
      return res;
    })

    console.log(uberEstimate);

    let ridequery = 'https://sandbox-api.uber.com/v1.2/requests'

    let uberRide = await reqProm({
      method: 'POST',
      url: ridequery,
      headers:{
          authorization: uberkey
      },
      body: {
        start_latitude: lat,
	      start_longitude:lon,
	      end_latitude:query.lat,
	      end_longitude:query.lon,
        fare_id: uberEstimate.fare_id
      },
      json: true
    }).then(function(q){
      console.log(q);
      return q;
    });

    let result = await lib.messagebird.tel.sms({
      originator: '12262860381',
      recipient: sender,
      // recipient: '6479936121',
      body: "Your request is processing. \n Fare estimate: $" + uberEstimate.cost +
            "\n Distance: " + uberEstimate.distance + "miles" +
            "\n Closest Driver: " + uberEstimate.time + "seconds"
    });

    // let acceptRide = 'https://sandbox-api.uber.com/v1.2/requests/' + uberRide.request_id;
    // console.log(acceptRide);
    // await reqProm({
    //   method: 'PUT',
    //   url: acceptRide,
    //   headers:{
    //       authorization: uberkey
    //   },
    //   body : {
    //     status: "accepted"
    //   },
    //   json: true
    // });
    // console.log("now we here")
    // await sleep(3000);
    //
    // let check = 'https://sandbox-api.uber.com/v1.2/requests/' + uberRide.request_id;
    // let checkStatus = await reqProm({
    //     method: 'GET',
    //     url: check,
    //     headers:{
    //         authorization: uberkey
    //     },
    //     json: true
    //   }).then(function(q){
    //     console.log(q);
    //     return q;
    //   });

      // let accept = await lib.messagebird.tel.sms({
      //   originator: '12262860381',
      //   recipient: sender,
      //   // recipient: '6479936121',
      //   body: "Your request is processing. \n Fare estimate: $" + uberEstimate.cost +
      //         "\n Distance: " + uberEstimate.distance + "miles" +
      //         "\n Closest Driver: " + uberEstimate.time + "seconds"
      // });

    let check = 'https://sandbox-api.uber.com/v1.2/requests/' + uberRide.request_id;
    let stay = true;
    let count = 0;

    while (stay && count < 20){
      await sleep(4000);
      let checkStatus = await reqProm({
        method: 'GET',
        url: check,
        headers:{
            authorization: uberkey
        },
        json: true
      }).then(function(q){
        console.log(q);
        return q;
      });

      if (checkStatus.status == "accepted"){
        let res = await lib.messagebird.tel.sms({
          originator: '12262860381',
          recipient: sender,
          // recipient: '6479936121',
          body: "Your ride has been accepted!" +
                "\n Driver: " + checkStatus.driver.name +
                "\n Phone number: " + checkStatus.driver.phone_number +
                "\n Rating: " + checkStatus.driver.rating +
                "\n Car: " + checkStatus.vehicle.name + " " + checkStatus.vehicle.make +
                "\n License Plate: " + checkStatus.vehicle.license_plate
        });
        stay = false;
      }
      else if (checkStatus.status == "rider_canceled"){
        let res = await lib.messagebird.tel.sms({
          originator: '12262860381',
          recipient: sender,
          // recipient: '6479936121',
          body: "You have canceled your ride"
        });
        stay = false;
      }
    count++;
    }
  }
  else if (split[0].toUpperCase() == 'HELP'){
    for (i = 0; i < split.length; i++){
      split[i] = split[i].replace(/ /g,"")
    }
    body = "Text help,<directions/places/weather> for more detailed information"
    if (split[1].toUpperCase() == "DIRECTIONS"){
      body = "The format for directions is \'<driving/transit/walking>,origin,destination\'"
    }
    else if (split[1].toUpperCase() == "PLACES"){
      body = "The format for places is \'description,keyword,location\'"
    }
    else if (split[1].toUpperCase() == "WEATHER"){
      body = "The format for weather is \'weather,city name\' or \'weather,latitude,longitude\'"
    }
    let result = await lib.messagebird.tel.sms({
      originator: '12262860381',
      recipient: sender,
      // recipient: '6479936121',
      body: body
    });
  }
  else {
    let result = await lib.messagebird.tel.sms({
    originator: '12262860381',
    recipient: sender,
    // recipient: '6479936121',
    body: "Invalid Instructions; text \"help\" for help"
    });
  }
};
