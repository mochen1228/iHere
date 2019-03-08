//
//  AddLocationViewController.swift
//  SignMeIn
//
//  Created by ChenMo on 3/5/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//
// References for MapKit:
// https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/
//

// TODO:
// Add the functionality to automatically search and assign a placemark
//      using the user's initial location (coordinates)
//      See onConfirmLocationButton

import UIKit
import MapKit

protocol AddLocationViewControllerDelegate {
    // Protocal for passing selected location to InstructorAddClassVC
    func finishPassing(location: MKPlacemark)
}

class AddLocationViewController: UIViewController, LocationSearchTableDelegate {
    
    func passSelectedLocation(location: MKPlacemark) {
        // Set of statements to run when received data from the search table
        // print("Placemark received:")
        // print(location)
        self.selectedLocation = location

        // Fill out the search bar text with the name of the selected location
        self.resultSearchController?.searchBar.text = location.name
    }
    
    var delegate: AddLocationViewControllerDelegate?
    
    // This view is shared with the search table
    @IBOutlet weak var mapView: MKMapView!
    
    // The location that the user selected from the search table
    //      (tapped cell of the table VC)
    var selectedLocation: MKPlacemark? = nil
    
    let locationManager = CLLocationManager()
    
    var resultSearchController:UISearchController? = nil

    @IBAction func onConfirmLocationButton(_ sender: Any) {
        // Dismiss this VC and go back to the previous InstructorAddClassVC
        // Pass a selected placemark as location data to IACVC
        
        // To prevent crashing when no location is selected
        if selectedLocation == nil {
            print("No location selected")
            return
        }
        
        delegate?.finishPassing(location: selectedLocation!)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Start loading location right away
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set initial location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

        // Setting up the search controller
        let storyboard = UIStoryboard(name: "InstructorHome", bundle: nil)
        let locationSearchTable = storyboard.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        
        // Setting delegate to receive data from search table
        locationSearchTable.delegate = self
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        // Set up these values with the search table
        locationSearchTable.mapView = mapView

        // Setting up the search bar for the search controller
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        // We want the search bar to always be present
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        // Nice to have feature for better aesthetics
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }

}

extension AddLocationViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            // Note, fixed the slow loading time by adding
            //    locationManager.startUpdatingLocation()
            // to viewWillAppear
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            locationManager.stopUpdatingLocation()
            print(locations)
        }
    }
}

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */
