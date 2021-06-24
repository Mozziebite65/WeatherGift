//
//  WeatherDetail.swift
//  WeatherGift
//
//  Created by Rick Martin on 18/06/2021.
//

import Foundation

// The dateFormatter() call is expensive, so we just want to make it once, outside the class
// Doing this OUTSIDE the class definition creates an instance that persists between creation and destruction of instances of the class itself.
// We can also set the dateFormat in here, as that will not change.
private let dateFormatter: DateFormatter = {
    
    var dateFormatter = DateFormatter()
    
    // Lets format the output to full day, abbreviated month, numeric day and full year
    // TO GET ANY DATE FORMATS WE WANT, GOOGLE "date format patterns unicode" and go to Unicode.org UTS #35 Dates - Date Format Patterns
    
    //dateFormatter.dateFormat = "EEE, MMM d, y H:mm"   // Short day, year, 24hr
    dateFormatter.dateFormat = "EEEE"   // Full day

    return dateFormatter
    
} ()

private let hourFormatter: DateFormatter = {
    
    var hourformatter = DateFormatter()
    
    // Lets format the output to full day, abbreviated month, numeric day and full year
    // TO GET ANY DATE FORMATS WE WANT, GOOGLE "date format patterns unicode" and go to Unicode.org UTS #35 Dates - Date Format Patterns
    
    //dateFormatter.dateFormat = "EEE, MMM d, y H:mm"   // Short day, year, 24hr
    hourformatter.dateFormat = "ha"   // hour, AM / PM

    return hourformatter
    
} ()

struct DailyWeather {
    
    var dailyIcon: String
    var dailyWeekday: String
    var dailySummary: String
    var dailyHigh: Int
    var dailyLow: Int
    
}

struct HourlyWeather {
    
    var hourlyIcon: String
    var hour: String
    var hourlyTemperature: Int
    
}

class WeatherDetail: WeatherLocation {
    
    // Structs to hold the weather data from the OpenWeather API data
    // Each "nested" level of data in the JSON has it's own struct
    
    // The top level
    private struct Result: Codable {
        
        var timezone: String
        var current: Current
        var daily: [Daily]
        var hourly: [Hourly]
    }
    
    // First nested level1 - "current"
    private struct Current: Codable {
        
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
        
    }
    
    // Second nested level
    private struct Weather: Codable {
        
        var description: String
        var icon: String
        var id: Int
        
    }
    
    // First nested level - "Daily"
    private struct Daily: Codable {
        
        var dt: TimeInterval
        var temp: Temp
        var weather: [Weather]
        
    }
    
    // Second nested level for "Daily"
    private struct Temp: Codable {
        
        var min: Double
        var max: Double
        
    }
    
    // First nested level - "Hourly"
    private struct Hourly: Codable {
        
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
        
    }
    
    
    var timezone = ""
    var currentTime = 0.0
    var temperature = 0
    var summary = ""
    var dayIcon = ""
    var dailyWeatherData: [DailyWeather] = []
    var hourlyWeatherData: [HourlyWeather] = []
    
    
    func getData(completed: @escaping () -> ()) {
        
        // the API call, taken directly from the openweather site. Note the "exclude" parameter, as we don't want the "minutely" part of the JSON. We can also change the unit of temperature from Kelvin to Celcius.
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longtitude)&exclude=minutely&units=metric&appid=\(APIkeys.openWeatherAPIKey)"
        
        print("🕸 We are accessing the url \(urlString)")
        
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
                //print("😎 \(result)")
                
                // The properties for the "current" weather
                self.timezone = result.timezone
                self.currentTime = result.current.dt
                self.temperature = Int(result.current.temp.rounded())
                self.summary = result.current.weather[0].description
                self.dayIcon = self.fileNameForIcon(openWeatherIconName: result.current.weather[0].icon)
                
                // The properties for the "daily" weather array
                //print("There are \(result.daily.count) days in the daily array...")

                for index in 0..<result.daily.count {
                    
                    let weekDay = Date(timeIntervalSince1970: result.daily[index].dt)
                    
                    // Adjust for time zone
                    dateFormatter.timeZone = TimeZone(identifier: result.timezone)
                    
                    let dailyWeather = DailyWeather(dailyIcon: self.fileNameForIcon(openWeatherIconName: result.daily[index].weather[0].icon),
                                                    dailyWeekday: dateFormatter.string(from: weekDay),
                                                    dailySummary: result.daily[index].weather[0].description,
                                                    dailyHigh: Int(result.daily[index].temp.max.rounded()),
                                                    dailyLow: Int(result.daily[index].temp.min.rounded())
                    )
                 
                    //print(dailyWeather)
                    self.dailyWeatherData.append(dailyWeather)
                    
                }
                
                // The properties for the "hourly" weather array
                //print("There are \(result.hourly.count) hours in the hourly array...")
                
                // Get no more that 24 hours of hourly data
                let lastHour = min(24, result.hourly.count)
                
                if lastHour > 0 {
                    
                    for index in 1...lastHour {
                        
                        //let weekDay = Date(timeIntervalSince1970: result.daily[index].dt)
                        let hourlyDate = Date(timeIntervalSince1970: result.hourly[index].dt)
                        
                        // Adjust for time zone
                        hourFormatter.timeZone = TimeZone(identifier: result.timezone)
                     
                        // For using the same weather icon as the Current area
                        let hourlyWeather = HourlyWeather(hourlyIcon: self.fileNameForIcon(openWeatherIconName: result.hourly[index].weather[0].icon),
                                                          hour: hourFormatter.string(from: hourlyDate),
                                                          hourlyTemperature: Int(result.hourly[index].temp.rounded())
                        )
                        
                        // For using the SF weather icons
//                        let hourlyWeather = HourlyWeather(hourlyIcon: self.systemNameFromID(weatherID: result.hourly[index].weather[0].id, icon: result.hourly[index].weather[0].icon),
//                                                          hour: hourFormatter.string(from: hourlyDate),
//                                                          hourlyTemperature: Int(result.hourly[index].temp.rounded())
//
//                        )
                        print("The hour is \(hourlyWeather)")
                        print("Hour: \(hourFormatter.string(from: hourlyDate)), Temperature: \(Int(result.hourly[index].temp.rounded())), Icon: \(self.fileNameForIcon(openWeatherIconName: result.hourly[index].weather[0].icon))")
                        
                        self.hourlyWeatherData.append(hourlyWeather)
                        
                    }
                    
                }
                
                
                
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
    
    private func systemNameFromID(weatherID: Int, icon: String) -> String {
        
        var sfSymbol: String
        
        switch weatherID {
        
        case 200...202:
            sfSymbol = "cloud.bolt.rain"
        case 210...232:
            sfSymbol = "cloud.bolt"
        case 300...399:
            sfSymbol = "cloud.drizzle"
        case 500, 501, 520, 521, 531:
            sfSymbol = "cloud.rain"
        case 502, 503, 504, 522:
            sfSymbol = "cloud.heavyrain"
        case 511, 611...616:
            sfSymbol = "sleet"
        case 600...602, 620...622:
            sfSymbol = "snow"
        case 701, 711, 741:
            sfSymbol = "cloud.fog"
        case 721:
            sfSymbol = (icon.hasSuffix("d") ? "sun.haze" : "cloud.fog")
        case 731, 751, 761, 762:
            sfSymbol = (icon.hasSuffix("d") ? "sun.dust" : "cloud.fog")
        case 771:
            sfSymbol = "wind"
        case 800:
            sfSymbol = (icon.hasSuffix("d") ? "sun.max" : "moon")
        case 801, 802:
            sfSymbol = (icon.hasSuffix("d") ? "cloud.sun" : "cloud.moon")
        case 803, 804:
            sfSymbol = "cloud"
        default:
            sfSymbol = "questionmark.diamond"
        }
        print("Symbol: \(sfSymbol)")
        return sfSymbol
        
    }
    
    
    
}
