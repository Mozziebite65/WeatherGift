//
//  HourlyCollectionViewCell.swift
//  WeatherGift
//
//  Created by Rick Martin on 24/06/2021.
//

import UIKit

class HourlyCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet var hourLabel: UILabel!
    @IBOutlet var hourlyTemperature: UILabel!
    @IBOutlet var hourlyImageView: UIImageView!
    
    // Use a property observer to populate the cell controls. Not necessary (we could fill in these details directly in cellForItemAt in LocationListVC) but better programming practice...
    // This keeps all cell modifications in this cell class 🤷🏻‍♂️
    
    var hourlyWeather: HourlyWeather! {
        
        didSet {
            
            hourLabel.text = hourlyWeather.hour
            hourlyTemperature.text = "\(hourlyWeather.hourlyTemperature)°"
            // For custom icons
            hourlyImageView.image = UIImage(named: hourlyWeather.hourlyIcon)
            // For SF icons
            //hourlyImageView.image = UIImage(systemName: hourlyWeather.hourlyIcon)
            
        }
        
    }
    
    
    
}
