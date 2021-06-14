
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
    var weatherLocations: [WeatherLocation] = []
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // check to see if weatherLocation is nil. If so, this will eventually be the users location. But for now we'll just use a placeholder
        if weatherLocation == nil {
            
            weatherLocation = WeatherLocation(name: "Current Location", latitude: 0.0, longtitude: 0.0)
            weatherLocations.append(weatherLocation)
            
        }
        
        loadLocations()
        updateUserInterface()
        
    }
    
    // Retrieve stored encoded locations
    func loadLocations() {
        
        // Get encoded data
        guard let encodedData = UserDefaults.standard.data(forKey: "weatherLocations") else {
            
            print("⚠️ WARNING: could not load Weather Locations from UserDefaults. This will always happen the first time the app is installed and run, so we can ignore this error...")
            return
            
        }
        
        // We have encoded data - get decoder object
        let decoder = JSONDecoder()
        
        // Try to decode the data object to an array
        if let weatherLocations = try? decoder.decode(Array.self, from: encodedData) as [WeatherLocation] {
            
            self.weatherLocations = weatherLocations
            
        } else {
            
            print("ERROR: Couldn't decode data read from UserDefaults.. 😡")
        }
        
    }
    
    func updateUserInterface() {
        
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
        destinationVC.weatherLocations = weatherLocations
        
    }
    
    @IBAction func unwindFromLocationsList(segue: UIStoryboardSegue) {
        
        let sourceVC = segue.source as! LocationListViewController
        
        // if the locations array has been modified in the listview, we'll update the version in this class
        // Right now we have to use the sourceVC.weatherLocations because it's not directly available
        weatherLocations = sourceVC.weatherLocations
        weatherLocation = weatherLocations[sourceVC.selectedLocationIndex]
        
        updateUserInterface()
        
    }
    
}
