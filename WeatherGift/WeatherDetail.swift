//
//  WeatherDetail.swift
//  WeatherGift
//
//  Created by Rick Martin on 18/06/2021.
//

import Foundation

class WeatherDetail: WeatherLocation {
    
    // Structs to hold the weather data from the OpenWeather API data
    // Each "nested" level of data in the JSON has it's own struct
    
    // The top level
    struct Result: Codable {
        
        var timezone: String
        var current: Current
        
    }
    
    // First nested level1 "current"
    struct Current: Codable {
        
        var dt: Double
        var temp: Double
        var weather: [Weather]
        
    }
    
    // Second nested level
    struct Weather: Codable {
        
        var description: String
        var icon: String
        
    }
    
    var timezone = ""
    var currentTime = 0.0
    var temperature = 0
    var summary = ""
    var dailyIcon = ""
    
    func getData(completed: @escaping () -> ()) {
        
        // the API call, taken directly from the openweather site. Note the "exclude" parameter, as we don't want the "minutely" part of the JSON. We can also change the unit of temperature from Kelvin to Celcius.
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longtitude)&exclude=minutely&units=metric&appid=\(APIkeys.openWeatherAPIKey)"
        
        //print("🕸 We are accessing the url \(urlString)")
        
        // Create a URL
        guard let url = URL(string: urlString) else {
            print("😡 ERROR: Could not create a URL from \(urlString)")
            completed()
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
                // This next line is just there to test if we can actually retrieve the data - it can eventually be replaced with JSON decoding
                //let json = try JSONSerialization.jsonObject(with: data!, options: [])
 
                // Decode the JSON data
                let decoder = JSONDecoder()
                let result = try decoder.decode(Result.self, from: data!)       // "decode" throws an error, so we're inside a do-catch
//                print("😎 \(result)")
//                print("The timezone for \(self.name) is \(result.timezone)")
                self.timezone = result.timezone
                self.currentTime = result.current.dt
                self.temperature = Int(result.current.temp.rounded())
                self.summary = result.current.weather[0].description
                self.dailyIcon = self.fileNameForIcon(openWeatherIconName: result.current.weather[0].icon)
                
            } catch {
                // if an error is thrown
                print("😡 JSON ERROR: \(error.localizedDescription)")
            }
            completed()

        }
        
        // REMEMBER TO DO THIS LINE!!!!!!!!!!
        task.resume()

    }
    
    
    private func fileNameForIcon(openWeatherIconName: String) -> String {
        
        var weatherIconName: String
        
        switch openWeatherIconName {
        case "01d":
            weatherIconName = "day_clear"
        case "01n":
            weatherIconName = "night_clear"
        case "02d", "04d":
            weatherIconName = "day_partial_cloud"
        case "02n", "04n":
            weatherIconName = "night_partial_cloud"
        case "03d", "03n":
            weatherIconName = "cloudy"
        case "09d", "10d":
            weatherIconName = "day_rain"
        case "09n", "10n":
            weatherIconName = "night_rain"
        case "11d":
            weatherIconName = "day_thunder"
        case "11n":
            weatherIconName = "night_thunder"
        case "13d":
            weatherIconName = "day_snow"
        case "13n":
            weatherIconName = "night_snow"
        case "50d", "50n":
            weatherIconName = "mist"
            
        default:
            weatherIconName = "day_clear"
        }
        
        return weatherIconName
        
    }
    
    
    
}
