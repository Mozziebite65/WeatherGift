//
//  PageViewController.swift
//  WeatherGift
//
//  Created by Rick Martin on 15/06/2021.
//

import UIKit

class PageViewController: UIPageViewController {

    var weatherLocations: [WeatherLocation] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        loadLocations()
        
        setViewControllers([createLocationDetailViewController(forPage: 0)], direction: .forward, animated: false, completion: nil)

    }
    
    // Retrieve stored encoded locations
    func loadLocations() {
        
        // Get encoded data
        guard let encodedData = UserDefaults.standard.data(forKey: "weatherLocations") else {
            
            // There isn't anything in UserDefaults. So probably the first time the app has been run. Show warning and create a new dummy value
            print("⚠️ WARNING: could not load Weather Locations from UserDefaults. This will always happen the first time the app is installed and run, so we can ignore this error...")
            
            // TODO: Get User Location for first element in the weatherLocations array
            weatherLocations.append(WeatherLocation(name: "", latitude: 0.0, longtitude: 0.0))
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
        
        // In case we get to here and there IS a valid data file, but it has nothing in it (shouldn't happen, but...)
        if weatherLocations.isEmpty {
            // TODO: Get User Location for first element in the weatherLocations array
            weatherLocations.append(WeatherLocation(name: "Current Location", latitude: 0.0, longtitude: 0.0))
        }
    }
    
    func createLocationDetailViewController(forPage page: Int) -> LocationDetailViewController {
        
        // Create a new instance of the LocationDetailVC
        let detailViewController = storyboard!.instantiateViewController(identifier: "LocationDetailViewController") as! LocationDetailViewController
        detailViewController.locationIndex = page
        return detailViewController
        
    }
    
}

extension PageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        // For swiping right i.e. to the previous page
        if let currentViewController = viewController as? LocationDetailViewController {
            
            // Make sure the current VC isn't the "first one"
            if currentViewController.locationIndex > 0 {
                
                return createLocationDetailViewController(forPage: currentViewController.locationIndex - 1)
                
            }
            
        }
        
        // If the above fails...
        return nil
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        // For swiping left i.e. to the NEXT page
        if let currentViewController = viewController as? LocationDetailViewController {
            
            // Make sure the VC isn't the LAST one
            if currentViewController.locationIndex < weatherLocations.count - 1 {
                
                return createLocationDetailViewController(forPage: currentViewController.locationIndex + 1)
                
            }
            
        }
        
        // If the above fails...
        return nil
        
    }
    
    
    
    
}
