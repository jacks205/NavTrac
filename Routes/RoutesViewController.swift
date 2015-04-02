//
//  DirectionsTableViewController.swift
//  Routes
//
//  Created by Mark Jackson on 3/21/15.
//  Copyright (c) 2015 Mark Jackson. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Alamofire
import SwiftyJSON

class RoutesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate, AddRouteProtocol {
    
    var locationManager : CLLocationManager?
    var directions : [Direction]?
    var searchDirections : [Direction]?
    var currentCoords : CLLocationCoordinate2D?
    
    var isSearching : Bool!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.isSearching = false
        
        // Add gradient background
        self.addGradientLayer()
        
        //Initializers
        self.initializeTableView()
        self.initializeSearchBar()
        self.initializeLocationManager()
        
        var tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTouch:")
        self.view.addGestureRecognizer(tap)
        
        
        //TODO: Remove and implement real dataset
        //Load in directions from user
        self.directions = []
        self.searchDirections = []
        for(var i = 0; i < 3; ++i){
            let dir : Direction = Direction(
                startingLocation: Location(areaOfInterest: "Home", streetNumber: "1", streetAddress: "Somewhere", city: "Sometown", state: "CA", county: "Orange", postalCode: "92866", country: "US"),
                endingLocation: Location(areaOfInterest: "Chapman University", streetNumber: "1", streetAddress: "University Dr", city: "Orange", state: "CA", county: "Orange", postalCode: "92866", country: "US"),
                viaDirections: ["I-55s", "Chapman"])
            dir.distance = 123412
            dir.trafficTime = 12313
            dir.travelTime = 213131
            self.directions?.append(dir)
        }
        for(var i = 0; i < 3; ++i){
            let dir : Direction = Direction(
                startingLocation: Location(areaOfInterest: "Home", streetNumber: "1", streetAddress: "Somewhere", city: "Sometown", state: "CA", county: "Orange", postalCode: "92866", country: "US"),
                endingLocation: Location(areaOfInterest: "Work", streetNumber: "1", streetAddress: "University Dr", city: "Orange", state: "CA", county: "Orange", postalCode: "92866", country: "US"),
                viaDirections: ["I-55s", "Chapman"])
            dir.distance = 13745
            dir.trafficTime = 13445
            dir.travelTime = 13445
            self.directions?.append(dir)
        }
        for(var i = 0; i < 3; ++i){
            let dir : Direction = Direction(
                startingLocation: Location(areaOfInterest: "Home", streetNumber: "1", streetAddress: "Somewhere", city: "Sometown", state: "CA", county: "Orange", postalCode: "92866", country: "US"),
                endingLocation: Location(areaOfInterest: "Winterfell", streetNumber: "1", streetAddress: "University Dr", city: "Orange", state: "CA", county: "Orange", postalCode: "92866", country: "US"),
                viaDirections: ["I-55s", "Chapman"])
            dir.distance = 139995
            dir.trafficTime = 135445
            dir.travelTime = 135245
            self.directions?.append(dir)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //Initialize Location Manager and update location
    func initializeLocationManager(){
        self.locationManager = CLLocationManager()
        if let locationManagerOp = self.locationManager{
            locationManagerOp.delegate = self;
            locationManagerOp.distanceFilter = kCLDistanceFilterNone
            locationManagerOp.desiredAccuracy = kCLLocationAccuracyBest
            locationManagerOp.requestWhenInUseAuthorization()
            locationManagerOp.startMonitoringSignificantLocationChanges()
            locationManagerOp.startUpdatingLocation()
        }
    }
    
    //Initializes table view and sets delegates
    func initializeTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.backgroundColor = UIColor.clearColor()
    }
    
    //Initializes search bar and sets delegates
    func initializeSearchBar(){
        self.searchBar.delegate = self
        UITextField.appearance().textColor = UIColor.whiteColor()
        self.searchBarView.backgroundColor = UIColor.clearColor()
    }
    
    //Creates and adds background gradient color
    func addGradientLayer(){
        var gradient : CAGradientLayer = CAGradientLayer()
        gradient.frame = self.view!.frame
        gradient.colors = [Colors.TableViewGradient.Start, Colors.TableViewGradient.End]
        self.view!.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    //For refreshing current routes and parsing data from API
    func refreshRoutes(){
        //Directions exist
        for direction in self.directions!{
            Alamofire.request(.GET, direction.buildUrl(self.currentCoords!)!, parameters: nil, encoding: ParameterEncoding.URL)
                .responseJSON(options: nil, completionHandler: { (
                    req, res, json, error) -> Void in
                    if(error != nil){
                        println("Error: \(error)")
                        println(req)
                        println(res)
                    }else{
                        let json = JSON(json!)
                        if let summary = json[Constants.RESPONSE_KEY][Constants.ROUTE_KEY][0][Constants.SUMMARY_KEY].string{
                            println(summary)
                            //TODO: Fix SwiftyJSON Parsing
                            //                                if let distance = summary[Constants.DISTANCE_KEY].int{
                            //                                    dir.distance = distance
                            //                                }
                            //                                if let baseTime = summary[Constants.BASE_TIME_KEY].int{
                            //                                    dir.baseTime = baseTime
                            //                                }
                            //                                if let trafficTime = summary[Constants.TRAFFIC_TIME_KEY].int{
                            //                                    dir.trafficTime = trafficTime
                            //                                }
                            //                                if let travelTime = summary[Constants.TRAVEL_TIME_KEY].int{
                            //                                    dir.travelTime = travelTime
                            //                                }
                        }else{
                            println("Error: \(json.string)")
                        }
                    }
                })
            self.tableView.reloadData()
        }
    }
    
    //MARK: TableView Delegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearching! {
            return self.searchDirections!.count
        }else{
            return self.directions!.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : RouteTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as RouteTableViewCell
        var directionEntry : Direction?
        if !self.isSearching! {
            directionEntry = self.directions![indexPath.row]
        }else{
            directionEntry = self.searchDirections![indexPath.row]
        }
        if let direction = directionEntry {
            cell.startLocation.text = direction.startingLocation?.areaOfInterest
            cell.endLocation.text =  direction.endingLocation?.areaOfInterest
            cell.setViaRouteDescription(direction.viaDirections)
            
            let distance = direction.distance
            let trafficTime = direction.trafficTime
            
            //Calculate user friendly values for distance and time
            let distanceString = metersToMilesString(Float(distance!))
            let trafficTimeString = secondsToHoursAndMinutesString(trafficTime!)
            
            cell.distanceLabel.text = distanceString;
            cell.totalTravelTime = trafficTimeString;
            
            //Must set this in the cellForRowAtIndexPath: method
            cell.backgroundColor = UIColor.clearColor()
        }
        return cell
    }
    
    //MARK: SearchBar Delegate Methods
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        //Check if user is searching for specific route
        if(countElements(searchText) > 0){
            //Populate searchDirections
            self.searchDirections?.removeAll(keepCapacity: false)
            for route in self.directions! {
                let rangeStartLocation : Range = Range<String.Index>(start: searchText.startIndex, end: route.startingLocation!.areaOfInterest.endIndex)
                if (route.startingLocation?.areaOfInterest.lowercaseString.rangeOfString(searchText.lowercaseString, options: NSStringCompareOptions.AnchoredSearch, range: rangeStartLocation, locale: nil) != nil) {
                    self.searchDirections?.append(route)
                }
                let rangeEndLocation : Range = Range<String.Index>(start: searchText.startIndex, end: route.endingLocation!.areaOfInterest.endIndex)
                if (route.endingLocation?.areaOfInterest.lowercaseString.rangeOfString(searchText.lowercaseString, options: NSStringCompareOptions.AnchoredSearch, range: rangeEndLocation, locale: nil) != nil) {
                    self.searchDirections?.append(route)
                }
            }
            self.isSearching = true
        }else{
            self.isSearching = false
        }
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
    
    //MARK: AddRouteProtocol
    //AddRouteProtocol method
    func addRouteViewControllerDismissed(startingLocation : Location, endingLocation : Location){
        //Create Direction out of locations
        
//        self.directions?.append(direction)
        self.tableView.reloadData()
    }
    
    //IBAction for addButton to add a route and present a modal
    @IBAction func addDirection(sender: AnyObject) {

    }
    
//    //Segue method
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println(segue.identifier! == "addRoute")
        if(segue.identifier! == "addRoute"){
            println(segue.destinationViewController)
            let navController : UINavigationController = segue.destinationViewController as UINavigationController
            println(navController.topViewController)
            let vc : AddStartRouteViewController? = navController.topViewController as? AddStartRouteViewController
            println(vc)
            if let addStartRouteController = vc  {
                println("CUURENTY COORDS")
                println(self.currentCoords)
                addStartRouteController.currentCoords = self.currentCoords
                addStartRouteController.directionTableDelegate = self
            }
        }
    }
    
    //MARK: Current Location Delegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location : CLLocation = locations.last as CLLocation
        self.currentCoords = location.coordinate
    }
    
    //MARK: Convienence Methods
    //Converts meters to a string containing miles and formated .2f
    func metersToMilesString(meters : Float) -> String{
        let distance = meters * 0.000621371
        return String(format: "%.1f mi", distance)
    }
    
    //Takes in total seconds and converts it to a string formatted "00h 00m"
    func secondsToHoursAndMinutesString(seconds : Int) -> String{
        let intSeconds = seconds;
        let hours = intSeconds / 3600;
        let minutes = intSeconds % 3600 / 60;
        return "\(hours) hrs \(minutes) min"
    }
    
    // Handler for dismissing keyboard
    func handleTouch(recognizer : UITapGestureRecognizer){
        if recognizer.view != self.searchBar && self.searchBar.isFirstResponder() {
            self.searchBar.resignFirstResponder()
        }
    }
    
    //MARK: Launching Map App
    func launchMapApp(coordinates : CLLocationCoordinate2D, name: String) -> Void{
        // Launching map app with location and name of destination
        let place : MKPlacemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let destination : MKMapItem = MKMapItem(placemark: place)
        destination.name = name;
        let items = [destination]
        let options = NSDictionary(object: MKLaunchOptionsDirectionsModeDriving, forKey: MKLaunchOptionsDirectionsModeKey)
        MKMapItem.openMapsWithItems(items, launchOptions: options)
    }
    
    
}

struct Alert {
    static func createAlertView(title : String, message : String, sender : AnyObject){
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
        sender.presentViewController(alert, animated: true, completion: nil)
    }
}

