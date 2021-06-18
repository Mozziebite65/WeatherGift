//
//  WeatherLocation.swift
//  WeatherGift
//
//  Created by Rick Martin on 08/06/2021.
//

import Foundation

class  WeatherLocation: Codable {
    
    var name: String
    var latitude: Double
    var longtitude: Double
    
    init(name: String, latitude: Double, longtitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longtitude = longtitude
    }
    
    func getData() {
        
        // the API call, taken directly from the openweather site. Note the "exclude" parameter, as we don't want the "minutely" part of the JSON. We can also change the unit of temperature from Kelvin to Celcius.
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longtitude)&exclude=minutely&units=metric&appid=\(APIkeys.openWeatherAPIKey)"
        //let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=54.6597778942174&lon=-5.656608772419188&appid=\(APIkeys.openWeatherAPIKey)"
        
        print("🕸 We are accessing the url \(urlString)")
        
        // Create a URL
        guard let url = URL(string: urlString) else {
            print("😡 ERROR: Could not create a URL from \(urlString)")
            return
        }
        
        // Create Session
        let session = URLSession.shared
        
        // Get data with .dataTask method
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print("😡 ERROR: \(error.localizedDescription)")
            }
            
            // Note: there are some additional things which could go wrong when using URLSession, but we shouldn't get them so we'll ignore testing for now...
            
            // Deal with the data
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                print("😎 \(json)")
            } catch {
                // if an error is thrown
                print("😡 JSON ERROR: \(error.localizedDescription)")
            }

        }
        
        // REMEMBER TO DO THIS LINE!!!!!!!!!!
        task.resume()
        
    }
    
}
