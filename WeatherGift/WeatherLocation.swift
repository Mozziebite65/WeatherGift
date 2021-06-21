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

}
