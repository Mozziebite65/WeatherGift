//
//  LocationListViewController.swift
//  WeatherGift
//
//  Created by Rick Martin on 08/06/2021.
//

import UIKit
import GooglePlaces

class LocationListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editBarButton: UIBarButtonItem!
    @IBOutlet var addBarButton: UIBarButtonItem!
    
    var weatherLocations: [WeatherLocation] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        weatherLocations = [WeatherLocation(name: "Bangor, Norn Iron", latitude: 0.0, longtitude: 0.0),
                            WeatherLocation(name: "Göttingen, Germany", latitude: 0.0, longtitude: 0.0),
                            WeatherLocation(name: "Ubud, Bali", latitude: -6.0, longtitude: 0.0)
        ]
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            addBarButton.isEnabled = true
            sender.title = "Edit"
        } else {
            tableView.setEditing(true, animated: true)
            addBarButton.isEnabled = false
            sender.title = "Done"
        }
    
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
        
    }
    
    
}

extension LocationListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return weatherLocations.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = weatherLocations[indexPath.row].name
        cell.detailTextLabel?.text = "Lat: \(weatherLocations[indexPath.row].latitude), Long: \(weatherLocations[indexPath.row].longtitude)"
        return cell
        
    }
    
    
    // Protocol function to delete rows
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            weatherLocations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

            //saveData()
        }
        
    }
    
    // Protocol function to move rows around
    // iOS will take care of the graphical table, but WE have to sync the data source array accordingly!!!!!!!
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        // To enable the source array in memory to keep in sync with the new table view ordering
        let itemToMove = weatherLocations[sourceIndexPath.row]                 // Store the item value
        weatherLocations.remove(at: sourceIndexPath.row)                       // Remove from the array
        weatherLocations.insert(itemToMove, at: destinationIndexPath.row)      // Re-insert the item in the same position in the array as it now is in the table
        
        //saveData()

    }

}

extension LocationListViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    
    let newLocation = WeatherLocation(name: place.name ?? "unknown location", latitude: place.coordinate.latitude, longtitude: place.coordinate.longitude)
    weatherLocations.append(newLocation)
    tableView.reloadData()
    dismiss(animated: true, completion: nil)
    
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }

}
