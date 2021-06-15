
//
//  LocationDetailViewController.swift
//  WeatherGift
//
//  Created by Rick Martin on 11/06/2021.
//
import UIKit

class LocationDetailViewController: UIViewController {
    

    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var summaryLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var weatherLocation: WeatherLocation!
    
    var locationIndex = 0
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        updateUserInterface()
        
    }
    
    func updateUserInterface() {
        
        // Get the page View Controller
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
        weatherLocation = pageViewController.weatherLocations[locationIndex]
        
        
        // Initial placeholder dummy data
        dateLabel.text = ""
        placeLabel.text = weatherLocation.name
        temperatureLabel.text = "---°"
        summaryLabel.text = "Blah blah blah..."

    }
    
    
    @IBAction func aboutButtonPressed(_ sender: UIBarButtonItem) {
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Pass the data array into the list view controller
        let destinationVC = segue.destination as! LocationListViewController
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
        destinationVC.weatherLocations = pageViewController.weatherLocations
        
    }
    
    @IBAction func unwindFromLocationsList(segue: UIStoryboardSegue) {
        
        let sourceVC = segue.source as! LocationListViewController
        locationIndex = sourceVC.selectedLocationIndex
        
        // if the locations array has been modified in the listview, we'll update the version in this class
        // Right now we have to use the sourceVC.weatherLocations because it's not directly available
        
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
        pageViewController.weatherLocations = sourceVC.weatherLocations
        pageViewController.setViewControllers([pageViewController.createLocationDetailViewController(forPage: locationIndex)], direction: .forward, animated: false, completion: nil)
        
    }
    
}
