//
//  DailyTableViewCell.swift
//  WeatherGift
//
//  Created by Rick Martin on 22/06/2021.
//

import UIKit

//protocol DailyTableViewCellDelegate: AnyObject {
//
//    // Actually, nothing is BEING delegated to the tableview / LocationDetailVC, so we don't need this AT ALL...
//}

class DailyTableViewCell: UITableViewCell {

    // Daily Table View stuff
    @IBOutlet var dailyImageView: UIImageView!
    @IBOutlet var dailyWeekdayLabel: UILabel!
    @IBOutlet var dailySummaryView: UITextView!
    @IBOutlet var dailyHighLabel: UILabel!
    @IBOutlet var dailyLowLabel: UILabel!

    //weak var delegate: DailyTableViewCellDelegate?
    
    // Use a property observer to populate the cell controls. Not necessary (we could fill in these details directly in cellForRowAt in LocationListVC) but better programming practice...
    // This keeps all cell modifications in this cell class 🤷🏻‍♂️
    
    var dailyWeather: DailyWeather! {
        
        didSet {
            dailyImageView.image = UIImage(named: dailyWeather.dailyIcon)
            dailyWeekdayLabel.text = dailyWeather.dailyWeekday
            dailySummaryView.text = dailyWeather.dailySummary
            dailyHighLabel.text = "\(dailyWeather.dailyHigh)°"
            dailyLowLabel.text = "\(dailyWeather.dailyLow)°"
        }
        
    }
}
