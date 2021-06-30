
//
//  LocationDetailViewController.swift
//  WeatherGift
//
//  Created by Rick Martin on 11/06/2021.
//
import UIKit
import CoreLocation

// The dateFormatter() call is expensive, so we just want to make it once, outside the class
// Doing this OUTSIDE the class definition creates an instance that persists between creation and destruction of instances of the class itself.
// We can also set the dateFormat in here, as that will not change.
private let dateFormatter: DateFormatter = {
    
    var dateFormatter = DateFormatter()
    
    // Lets format the output to full day, abbreviated month, numeric day and full year
    // TO GET ANY DATE FORMATS WE WANT, GOOGLE "date format patterns unicode" and go to Unicode.org UTS #35 Dates - Date Format Patterns
    
    //dateFormatter.dateFormat = "EEE, MMM d, y H:mm"   // Short day, year, 24hr
    //dateFormatter.dateFormat = "EEEE, MMM d, h:mm aaa"   // Full day, no year, AM / PM
    dateFormatter.dateFormat = "EEEE, MMM d"   // Full day, Month
    
    return dateFormatter
    
}()

class LocationDetailViewController: UIViewController {
    

    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var summaryLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var collectionview: UICollectionView!
    
    var weatherDetail: WeatherDetail!
    var rowHeight: CGFloat = 80
    var locationIndex = 0
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)

        // This code was in viewDIDLOAD - it's better in here...
        
        // Clear out the dummy data
        clearUserInterface()
        
        // ************ DON'T FORGET THESE LINES!!!!! ***************
        // Set the data source and delegate - this requires the class to conform to the protocols....
        tableView.dataSource = self
        tableView.delegate = self
        
        collectionview.dataSource = self
        collectionview.delegate = self
        
        // Get the location of the user - only do this when we're at locationIndex = 0 (the first page when the app loads)
        if locationIndex == 0 {
            
            getLocation()
            
        }
        
        updateUserInterface()
        
    }
    
    
    func updateUserInterface() {
        
        // Get the page View Controller
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
        let weatherLocation = pageViewController.weatherLocations[locationIndex]
        
        // Initialise the weatherDetail object - it inherits the parameters from WeatherLocation, its parent class
        weatherDetail = WeatherDetail(name: weatherLocation.name, latitude: weatherLocation.latitude, longtitude: weatherLocation.longtitude)
        
        // Make the API call for the location
        weatherDetail.getData {
            
            // Because this code is in an escaping closure, which runs in the background, we need to move this back to the main thread
            DispatchQueue.main.async {
                
                //self.dateLabel.text = "\(self.weatherDetail.timezone)"
                self.dateLabel.text = self.getFormattedLocalTime(forTimeZone: self.weatherDetail.timezone, forAPITime: self.weatherDetail.currentTime)
                self.placeLabel.text = self.weatherDetail.name
                self.temperatureLabel.text = "\(self.weatherDetail.temperature)°"
                self.summaryLabel.text = self.weatherDetail.summary
                self.imageView.image = UIImage(named: self.weatherDetail.dayIcon)
                
                // Do the daily forecast table
                self.tableView.reloadData()
                
                // and the collection view of hourly data
                self.collectionview.reloadData()
                
            }

        }

        pageControl.numberOfPages = pageViewController.weatherLocations.count
        pageControl.currentPage = locationIndex
        
    }
    
    func clearUserInterface() {
        
        // Function to clear out the "placeholder" data in the current weather area
        dateLabel.text = ""
        placeLabel.text = ""
        temperatureLabel.text = ""
        summaryLabel.text = ""
        imageView.image = UIImage()

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
        
        if segue.identifier == "ShowList" {
            
            // Pass the data array into the list view controller
            let destinationVC = segue.destination as! LocationListViewController
            let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
            destinationVC.weatherLocations = pageViewController.weatherLocations
            
        }
        
        
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
    

extension LocationDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return weatherDetail.dailyWeatherData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // When we changed the cell to a custom cell, we created a new cell subclass so we can access the custom cell elements and their IBoutlets.
        // So we have to SUBCLASS the class returned from the dequeue call
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DailyTableViewCell     // Force the subclassing
        
        // Set the delegate for the custom cell - DON'T NEED THIS FOR THIS PARTICULAR APP! Nothing is actually BEING delegated to the tableview... 
        //cell.delegate = self
        
        // Use the custom cell class property observer to fill in the cell contents, rather than doing it in here
        cell.dailyWeather = weatherDetail.dailyWeatherData[indexPath.row]
        
        // (We could have done it directly, like this.. But using the property observer is better programming.)
        //cell.dailySummaryView.text = weatherDetail.dailyWeatherData[indexPath.row].dailySummary
        //cell.dailyWeekdayLabel.text = weatherDetail.dailyWeatherData[indexPath.row].dailyWeekday
        //etc....
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return rowHeight
        
    }
    
}

extension LocationDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return weatherDetail.hourlyWeatherData.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Just the same as the tableView cellForRowAt...
        let hourlyCell = collectionview.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyCollectionViewCell
        
        hourlyCell.hourlyWeather = weatherDetail.hourlyWeatherData[indexPath.row]
        
        return hourlyCell
        
    }
    
}

// Location management extensions...

extension LocationDetailViewController: CLLocationManagerDelegate {
    
    // Programmer defined functions
    func getLocation() {
        
        // Creating a CLLocationManager object will automatically check the authorization given by the user, using the didChangeAuthorization function below...
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
    }
    
    func handleAuthorizationStatus(status: CLAuthorizationStatus) {
        
        switch status {

        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            oneButtonAlert(title: "Location Services Denied", message: "It may be that parental controls are restricting location use in this app.")
        case .denied:
            showAlertToPrivacySettings(title: "Location Services Denied", message: "Select 'Settings' below to enter device settings and enable Location Services for this app.")
            break
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print("😡 DEVELOPER ALERT: Unknown case of status in handleAuthorizationStatus\(status)")
            
        }
        
    }
    
    // Function to allow user to change their privacy settings
    func showAlertToPrivacySettings(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            
            print("😡ERROR: Something went wrong getting the UIApplication.openSettingsURLString..")
            return
            
        }
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)

    }
    
    
    // Apple pre-designed functions
    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {      // this function definition differs from the Prof J version in ch6.19 (deprecated)
//
//        print("👮🏼‍♂️ Checking authorization status..")
//        handleAuthorizationStatus(status: locationManager.authorizationStatus)
//
//    }
    
    // Deprecated version....
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        print("👮🏼‍♂️ Checking authorization status..")
        //Call helper function above..
        handleAuthorizationStatus(status: status)
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("📍 Updating location...")
        // The LAST location in the passed in "locations" array of CLLocations is typically the most accurate... apparently. 🤷🏻‍♂️
        let currentLocation = locations.last ?? CLLocation()    // nil coalescing
        
        print("Current location is \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            
            var locationName = ""
            if placemarks != nil {
                
                // Get the first placemark
                let placemark = placemarks?.last
                
                // assign placemark to locationName
                locationName = placemark?.name ?? "Parts unknown"
                
            } else {
                
                print("😡 ERROR: Could not retrieve place.")
                locationName = "Could not find location."
                
            }
            print("📍📍 Location name = \(locationName)")
            
            // Update weatherLocations[0] with the current location so it can be used in updateUserInterface. getLocation() ONLY called when locationIndex == 0
            let newCurrentLocation = WeatherLocation(name: locationName, latitude: currentLocation.coordinate.latitude, longtitude: currentLocation.coordinate.longitude)
            let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
            pageViewController.weatherLocations[self.locationIndex] = newCurrentLocation
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("😡 ERROR: \(error.localizedDescription) Failed to get device location.")
        
    }
}
