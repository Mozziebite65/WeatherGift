
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
    
    @IBOutlet var pageControl: UIPageControl!
    
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
        
        // Make the API call for the location (does nothing YET..)
        weatherLocation.getData()
        
        // Initial placeholder dummy data
        dateLabel.text = ""
        placeLabel.text = weatherLocation.name
        temperatureLabel.text = "---°"
        summaryLabel.text = "Blah blah blah..."

        pageControl.numberOfPages = pageViewController.weatherLocations.count
        pageControl.currentPage = locationIndex
        
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
    
    @IBAction func pageControlTapped(_ sender: UIPageControl) {
        
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
        
        // Make the animation go left to right if we tap on the left side of the page control
        // The "sender.currentPage" is the screen we're transitioning TO! (confusingly named, I think!)
        var direction: UIPageViewController.NavigationDirection = .forward
        
        if sender.currentPage < locationIndex {
            direction = .reverse
        }
        
        // And use the "direction" variable as the parameter instead of .forward or .reverse
        pageViewController.setViewControllers([pageViewController.createLocationDetailViewController(forPage: sender.currentPage)], direction: direction, animated: true, completion: nil)
        
        // COULD have also just done it like this 🤷🏻‍♂️
//        if sender.currentPage < locationIndex {
//            pageViewController.setViewControllers([pageViewController.createLocationDetailViewController(forPage: sender.currentPage)], direction: .reverse, animated: true, completion: nil)
//        } else {
//            pageViewController.setViewControllers([pageViewController.createLocationDetailViewController(forPage: sender.currentPage)], direction: .forward, animated: true, completion: nil)
//        }
        
    }
    
}
