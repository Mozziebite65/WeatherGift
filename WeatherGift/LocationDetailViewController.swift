
//
//  LocationDetailViewController.swift
//  WeatherGift
//
//  Created by Rick Martin on 11/06/2021.
//
import UIKit

// The dateFormatter() call is expensive, so we just want to make it once, outside the class
// Doing this OUTSIDE the class definition creates an instance that persists between creation and destruction of instances of the class itself.
// We can also set the dateFormat in here, as that will not change.
private let dateFormatter: DateFormatter = {
    
    var dateFormatter = DateFormatter()
    
    // Lets format the output to full day, abbreviated month, numeric day and full year
    // TO GET ANY DATE FORMATS WE WANT, GOOGLE "date format patterns unicode" and go to Unicode.org UTS #35 Dates - Date Format Patterns
    
    //dateFormatter.dateFormat = "EEE, MMM d, y H:mm"   // Short day, year, 24hr
    dateFormatter.dateFormat = "EEEE, MMM d, h:mm aaa"   // Full day, no year, AM / PM

    return dateFormatter
    
}()

class LocationDetailViewController: UIViewController {
    

    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var summaryLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var pageControl: UIPageControl!

    var weatherDetail: WeatherDetail!
    
    var locationIndex = 0
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        updateUserInterface()
        
    }
    
    func updateUserInterface() {
        
        // Get the page View Controller
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
        let weatherLocation = pageViewController.weatherLocations[locationIndex]
        
        // Initialise the weatherDetail object - it inherits the parameters from WeatherLocation, its parent class
        weatherDetail = WeatherDetail(name: weatherLocation.name, latitude: weatherLocation.latitude, longtitude: weatherLocation.longtitude)
        
        // Make the API call for the location (does nothing YET..)
        weatherDetail.getData {
            
            // Because this code is in an escaping closure, which runs in the background, we need to move this back to the main thread
            DispatchQueue.main.async {
                
                //self.dateLabel.text = "\(self.weatherDetail.timezone)"
                self.dateLabel.text = self.getFormattedLocalTime(forTimeZone: self.weatherDetail.timezone, forAPITime: self.weatherDetail.currentTime)
                self.placeLabel.text = self.weatherDetail.name
                self.temperatureLabel.text = "\(self.weatherDetail.temperature)°"
                self.summaryLabel.text = self.weatherDetail.summary
                self.imageView.image = UIImage(named: self.weatherDetail.dailyIcon)
                
            }
        }


        pageControl.numberOfPages = pageViewController.weatherLocations.count
        pageControl.currentPage = locationIndex
        
    }
    
    func getFormattedLocalTime(forTimeZone timeZone: String, forAPITime unixTimeString: TimeInterval) -> String {
        
        // We could make this fuction do the same in 2 lines, but hey...

        let usableDate = Date(timeIntervalSince1970: unixTimeString)

        // Adjust for time zone
        let locationTimeZone = TimeZone(identifier: timeZone)
        
        // dateFormatter variable created outside class at top...
        dateFormatter.timeZone = locationTimeZone

        let formattedDate = dateFormatter.string(from: usableDate)
        return formattedDate

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
