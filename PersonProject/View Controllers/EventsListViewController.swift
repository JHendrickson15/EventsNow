//
//  EventsListViewController.swift
//  PersonProject
//
//  Created by Jordan Hendrickson on 7/9/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class EventsListViewController: UIViewController {
    
    @IBOutlet weak var searchBar: CustomSearchBar!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventsTableViewHeight: NSLayoutConstraint!
    
    var doneCreating: Bool = false
    
    let debouncer = Debouncer(timeInterval: 1.0)
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var searchByLocation: Bool = true
    var pins: [MKPointAnnotation] = []
    var location: [Event] = [] {
        didSet{
            DispatchQueue.main.async {
                self.eventsTableView.reloadData()
                self.addPinsToMap()
            }
        }
    }
    func shouldAutoRotate() -> Bool {
        return false
    }
    
    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return .portrait
    }
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        shouldAutoRotate()
        supportedInterfaceOrientations()
        self.searchBar.delegate = self
        self.eventsTableView.delegate = self
        self.eventsTableView.dataSource = self
        mapView.delegate = self
        debouncer.handler = {
            guard let searchText = self.searchBar.text else {return}
            guard self.checkStateOnlySearch(inText: searchText) == false else {
                self.presentSearchTermAlert()
                return
            }
            self.searchByLocation = false
            EventsController.shared.fetchEvents(searchTerm: searchText) { (locations) in
                EventsController.shared.events = locations ?? []
                self.location = locations ?? []
                DispatchQueue.main.async {
                    self.view.endEditing(true)
                }
            }
        }
        //core location request
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == CLAuthorizationStatus.notDetermined{
            locationManager?.requestWhenInUseAuthorization()
            print("No permissions here😳😳😳😳")
        }else{
            print("we got them permissions🤗🤗🤗🤗")
            mapView.showsUserLocation = true
            if locationManager?.location == nil{
                locationManager?.startUpdatingLocation()
            }
            self.location = EventsController.shared.events
        }
                eventsTableViewHeight.constant = 100 * 8
                self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if doneCreating {
            resetViews()
            doneCreating = false
            tabBarController?.selectedIndex = 0
        }
    }
    
    func resetViews(){
        self.searchBar.text = ""
        EventsController.shared.events = []
        DispatchQueue.main.async {
            self.eventsTableView.reloadData()
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationManager?.startUpdatingLocation()
        }
    }
    
    func checkStateOnlySearch(inText text: String) -> Bool{
        let stateNames = ["alabama", "alaska", "arizona", "arkansas", "california", "colorado", "connecticut", "delaware", "florida", "georgia", "hawaii", "idaho", "illinois", "indiana", "iowa", "kansas", "kentucky", "louisiana", "maine", "maryland", "massachusetts", "michigan", "minnesota", "mississippi", "missouri", "montana", "nebraska", "nevada", "new hampshire", "new jersey", "new mexico", "new york", "north carolina", "north dakota", "ohio", "oaklahoma", "oregon", "pennsylvania", "rhode island", "south carolina", "south dakota", "tennessee", "texas", "utah", "vermont", "virginia", "washington", "west virginia", "wisconsin", "wyoming"]
        let stateAbbreviations = ["al", "ak", "as", "az", "ar", "ca", "co", "ct", "de", "dc", "fl", "ga", "hi", "id", "il", "in", "ia", "ks", "ky", "la", "me", "md", "ma", "mi", "mn", "ms", "mo", "mt", "ne", "nv", "nh", "nj", "nm", "ny", "nc", "nd", "oh", "ok", "or", "pa", "ri", "sc", "sd", "tn", "tx", "ut", "vt", "va", "wa", "wv", "wi", "wy"]
        let lowercasedText = text.lowercased()
        let filteredText = lowercasedText.trimmingCharacters(in: NSCharacterSet.letters.inverted)
        print(filteredText)
        if filteredText.count == 2{
            return stateAbbreviations.contains(filteredText)
        } else {
            return stateNames.contains(filteredText)
        }
    }
    
    func presentSearchTermAlert(){
        let searchTermAlert = UIAlertController(title: "Hold on.", message: "Please enter a city and state. Just a state won't do.", preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Got it.", style: .default) { (action) in
            searchTermAlert.dismiss(animated: true, completion: nil)
        }
        searchTermAlert.addAction(closeAction)
        self.present(searchTermAlert, animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventsToDetailVC" {
            if let index = eventsTableView.indexPathForSelectedRow?.row {
                let destinationVC = segue.destination as? EventsCreationViewController
                
                let locations = EventsController.shared.events[index]
                destinationVC?.location = locations
            }
        }
    }
}

extension EventsListViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.searchByLocation == true {
            print("searching by location😙")
            self.currentLocation = locations[locations.count-1] as CLLocation
            guard let latitude = currentLocation?.coordinate.latitude, let longitude = currentLocation?.coordinate.longitude else {return}
            EventsController.shared.fetchEventsWithCoords(searchTerm: "city", latitude: latitude, longitude: longitude) { (fetchedEvents) in
                guard let location = fetchedEvents else {return}
                self.location = location
                EventsController.shared.events = location
                DispatchQueue.main.async {
                    self.eventsTableView.reloadData()
                    self.locationManager?.stopUpdatingLocation()
                }
            }
        }
    }
}

extension EventsListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventsController.shared.events.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as? EventsListTableViewCell
        
        let selectedEvent = EventsController.shared.events[indexPath.row]
        
        cell?.EventsResults = selectedEvent
        print("labelhasbeenchanged")
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension EventsListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        debouncer.renewInterval()
    }
}

extension EventsListViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else {return nil}
        
        let identifier = "Pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        }else{
            annotationView!.annotation = annotation
        }
        return annotationView
    }
    
    func addPinsToMap(){
        mapView.removeAnnotations(pins)
        self.pins = []
        for event in self.location{
            let newPin = MKPointAnnotation()
            newPin.title = event.name
            
            newPin.coordinate = CLLocationCoordinate2D(latitude: Double(event._embedded.venues.first?.location.latitude ?? "0.0 ") ?? 0.0, longitude: Double(event._embedded.venues.first?.location.longitude ?? "0.0 ") ?? 0.0)
            
            mapView.addAnnotation(newPin)
            self.pins.append(newPin)
        }
        print("location manager has no location")
        mapView.showAnnotations(pins, animated: true)
    }
    func findDistanceToUser(event: Event) -> CLLocationDistance{
        let eventCoordinate = CLLocationCoordinate2D(latitude: Double(event._embedded.venues.first?.location.latitude ?? "0.0") ?? 0.0, longitude: Double(event._embedded.venues.first?.location.longitude ?? "0.0") ?? 0.0)
        guard let currentAltitude = currentLocation?.altitude, let userLocation = currentLocation else {return 0}
        let eventLocation = CLLocation(coordinate: eventCoordinate, altitude: currentAltitude, horizontalAccuracy: 1, verticalAccuracy: -1, timestamp: Date())
        let distanceToUser = eventLocation.distance(from: userLocation)
        return distanceToUser
    }
}



