//
//  LocationSearchTable.swift
//  SignMeIn
//
//  Created by ChenMo on 3/5/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//

import UIKit
import MapKit

protocol LocationSearchTableDelegate {
    // Protocal for passing selected location to AddLocationViewController
    func passSelectedLocation(location: MKPlacemark)
}

class LocationSearchTable : UITableViewController {
    var delegate: LocationSearchTableDelegate?
    
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    // var selectedLocation: MKPlacemark? = nil
    var pin = MKPointAnnotation()
    // var searchController: UISearchController? = nil

    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between street number and street name
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between city names
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
}

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // ATTENTION:
        // The problem with the MKLocalSearch is that, it gives result from
        //      outside of the map area. We might need to consider using
        //      Google Places
        // TODO:
        // Replace MKLocalSearch with Google Places API
        guard let mapView = mapView,
        let searchBarText = searchController.searchBar.text else {
            return
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        print(mapView.region.center)
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

extension LocationSearchTable {
    // Extension protocols for tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Fill in the search bar text with the place selected
        
        // To center the map to the search result that is selected
        let selectedPlacemark = matchingItems[indexPath.row].placemark
        
        var region = MKCoordinateRegion()
        region.center = selectedPlacemark.coordinate
        region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        mapView?.setRegion(region, animated: true)

        // Drop a pin annotation to the map
        // Add the name of the place to the pin
        // When tapped the pin, it will display the address of the pin
        //      as the subtitle
        mapView?.removeAnnotation(pin)
        pin.title = selectedPlacemark.name
        // searchController?.searchBar.text = selectedPlacemark.name
        pin.subtitle = parseAddress(selectedItem: selectedPlacemark)
        pin.coordinate = region.center
        mapView?.addAnnotation(pin)
        
        // Pass placemark back to addLocationVC
        delegate?.passSelectedLocation(location: selectedPlacemark)
        
        // Dismiss the search tableview controller and bring back the map
        self.dismiss(animated: true, completion: nil)
    }
}

