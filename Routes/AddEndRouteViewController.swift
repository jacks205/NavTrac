//
//  AddEndRouteViewController.swift
//  Routes
//
//  Created by Mark Jackson on 3/29/15.
//  Copyright (c) 2015 Mark Jackson. All rights reserved.
//

import UIKit
import MapKit

class AddEndRouteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    
    var directionTableDelegate : AddRouteProtocol?
    var currentCoords : CLLocationCoordinate2D?
    
    var startingLocation : Location?
    
    var locations : [Location]
    var selectedCellIndexPath : NSIndexPath?
    
    required init(coder aDecoder: NSCoder) {
        self.locations = []
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Initialization
        self.searchBarView.backgroundColor = UIColor(CGColor: Colors.TableViewGradient.End)
        self.nextButton.backgroundColor = UIColor(CGColor: Colors.TableViewGradient.End)
        self.view.backgroundColor = UIColor(CGColor: Colors.IndicatorBackground)
        self.view.opaque = true
        self.view.alpha = 1
        self.initializeTableView()
        self.initializeSearchBar()
    }
    
    func initializeSearchBar(){
        self.searchBar.delegate = self
        UITextField.appearance().textColor = UIColor.whiteColor()
        
        //TODO: For convienence
        self.searchBar.text = "Whittier College"
    }
    
    //Initializes table view and sets delegates
    func initializeTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = true
        self.tableView.backgroundColor = UIColor.clearColor()
    }
    
    
    @IBAction func cancelModal(sender : AnyObject){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func back(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func routeClick(sender: AnyObject) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier! == "receiptRoute"){
            if let cellIndexPath = self.selectedCellIndexPath, endLocation : Location? = self.locations.get(cellIndexPath.row){
                let vc : ReceiptViewController = segue.destinationViewController as! ReceiptViewController
                if let location = endLocation {
                    vc.startingLocation = self.startingLocation
                    vc.endingLocation = location
                }
            }else{
                //TODO: Can change this by hiding next button instead
                Alert.createAlertView("Oops.", message: "Please select end location.", sender: self)
            }
        }
    }

    //MARK: Table View Delegate/Datasource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locations.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : LocationTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("LocationCell2") as! LocationTableViewCell
        
        if let location = self.locations.get(indexPath.row){
            if let areaOfInterest = location.areaOfInterest{
                cell.locationNameLabel.text = areaOfInterest
            }
            if let addressString = location.buildAddressString(){
                cell.locationAddressLabel.text = addressString
            }

            let pinImage : UIImageView = UIImageView(frame: CGRectMake(24, 26, 20, 24))
            pinImage.image = UIImage(named: "pin", inBundle: NSBundle.mainBundle(), compatibleWithTraitCollection: nil)
            pinImage.tag = 100
            cell.contentView.addSubview(pinImage)
        }
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView.backgroundColor = UIColor(CGColor: Colors.CellSelectionColor)
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    //MARK: SearchBar Delegate Methods
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if(count(searchBar.text) > 0){
            self.changeSelectedCell(nil)
            self.locations.removeAll(keepCapacity: false)
            let req : MKLocalSearchRequest = MKLocalSearchRequest()
            if let currentPosition = self.currentCoords{
                req.region = MKCoordinateRegionMakeWithDistance(currentPosition, 50000, 50000)
            }
            req.naturalLanguageQuery = searchText
            let localSearch : MKLocalSearch = MKLocalSearch(request: req)
            localSearch.startWithCompletionHandler { (res : MKLocalSearchResponse!, error : NSError!) -> Void in
                if error != nil{
                    println(error.localizedDescription)
                    //                self.tableView.reloadData()
                }else{
                    if let mapItems = res.mapItems as? [MKMapItem]{
                        for item in mapItems{
                            let newLocation : Location = Location(areaOfInterest: item.name, mapItem: item)
                            self.locations.append(newLocation)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.changeSelectedCell(indexPath)
        self.searchBar.resignFirstResponder()
    }
    
    func changeSelectedCell(indexPath : NSIndexPath?){
        if let selectedRow = self.selectedCellIndexPath{
            self.tableView.deselectRowAtIndexPath(selectedRow, animated: false)
            if selectedRow == indexPath {
                self.selectedCellIndexPath = nil
                self.nextButton.backgroundColor = UIColor(CGColor: Colors.TableViewGradient.End)
            }else{
                self.selectedCellIndexPath = indexPath
                self.nextButton.backgroundColor = UIColor(CGColor: Colors.TrafficColors.GreenLight)
            }
        }else{
            if let index = indexPath{
                self.selectedCellIndexPath = index
                self.nextButton.backgroundColor = UIColor(CGColor: Colors.TrafficColors.GreenLight)
            }else{
                self.nextButton.backgroundColor = UIColor(CGColor: Colors.TableViewGradient.End)
            }
            
        }
    }
    
    //Handles dismissing keyboard when uitableview is selectable
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
    
    // Handler for dismissing keyboard
    func handleTouch(recognizer : UITapGestureRecognizer){
        if recognizer.view != self.searchBar && self.searchBar.isFirstResponder() {
            self.searchBar.resignFirstResponder()
        }
    }
}