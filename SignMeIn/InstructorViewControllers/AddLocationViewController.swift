//
//  AddLocationViewController.swift
//  SignMeIn
//
//  Created by ChenMo on 3/5/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//
// https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var selectedLocation: MKPlacemark? = nil
    
    let locationManager = CLLocationManager()
    
    var resultSearchController:UISearchController? = nil


//    let initialLocation = CLLocation(latitude: 33.645936,
//                                     longitude: -117.842728)
//    let regionRadius: CLLocationDistance = 1000
    
    
    @IBAction func onConfirmButton(_ sender: Any) {
        
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
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        // Set up these values with the search table
        locationSearchTable.mapView = mapView
        locationSearchTable.selectedLocation = selectedLocation
        locationSearchTable.searchController = resultSearchController
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
