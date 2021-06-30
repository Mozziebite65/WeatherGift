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
    
    // Catcher / pitcher variable to hold info about the cell clicked which triggers the unwind
    var selectedLocationIndex = 0
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    // Save the locations to a local place on device
    func saveLocations() {
        
        // Get encoder object
        let encoder = JSONEncoder()
        
        // Try to encode the array to a data object
        if let encodedData = try? encoder.encode(weatherLocations) {
            
            // Here, we're not using the Dictionary URL method. Just writing to the UserDefaults location (easier for non-vital, non-sensitive info..)
            UserDefaults.standard.set(encodedData, forKey: "weatherLocations")
            
        } else {
            
            print("ERROR: Saving encodedData didn't work.. 😡")
        }

    }
    
    
    // Store the selected index path and save the data, and exit in unwind segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        selectedLocationIndex = tableView.indexPathForSelectedRow!.row
        saveLocations()
        
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
        //cell.detailTextLabel?.text = "Lat: \(weatherLocations[indexPath.row].latitude), Long: \(weatherLocations[indexPath.row].longtitude)"
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
    
    // MARK: tableViewMethods to "freeze" the first cell (current location) in place
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return (indexPath.row != 0 ? true : false)
        
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        return (indexPath.row != 0 ? true : false)
        
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        
        // Don't allow another row to be moved into position 0 - send it back to where it started!! ⛔️👮🏼‍♂️✋
        return (proposedDestinationIndexPath.row == 0 ? sourceIndexPath : proposedDestinationIndexPath)
        
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

}
