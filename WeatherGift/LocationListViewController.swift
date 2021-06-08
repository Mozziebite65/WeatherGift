//
//  LocationListViewController.swift
//  WeatherGift
//
//  Created by Rick Martin on 08/06/2021.
//

import UIKit

var weatherLocations: [WeatherLocation] = []

class LocationListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editBarButton: UIBarButtonItem!
    @IBOutlet var addBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        weatherLocations = [WeatherLocation(name: "Bangor, Norn Iron", latitude: 0.0, longtitude: 0.0),
                            WeatherLocation(name: "Göttingen, Germany", latitude: 0.0, longtitude: 0.0),
                            WeatherLocation(name: "Ubud, Bali", latitude: 0.0, longtitude: 0.0)
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
