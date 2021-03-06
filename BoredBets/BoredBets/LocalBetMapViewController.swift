//
//  LocalBetMapViewController.swift
//  BoredBets
//
//  Created by Markus Notti on 10/23/16.
//  Copyright © 2016 SauceKitchen. All rights reserved.
//

import UIKit
import GoogleMaps

class LocalBetMapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, MapDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var containerView: UIView!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var listView: UITableView!
    @IBOutlet var toggleViewButton: UIButton!
    
    
    var locationManager: CLLocationManager!
    var camera: GMSCameraPosition!
    //lat and long should be changed with the map's location
    var lat = 37.33233141
    var long = -122.0312186
    var radius = 5.0
    var map: Map!
    var selectedBet: Bet!
    var showMap: Bool!
    var bets: [Bet] = []
    var betsLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map = Map(mapView: mapView, showMarkers: true)
        map.delegate = self
        long = map.long
        lat = map.lat
        showMap = true
       
        self.listView.register(BetListCell.self, forCellReuseIdentifier: "Cell")
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        self.containerView.addSubview(toggleViewButton)
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.isTranslucent = false
//        var nc: UINavigationController = navigationController
        setupMenuBar()
        setupSearchButton()
    }
    
    let menuBar: MenuBar = {
        let mb = MenuBar()
        return mb
    }()
    
    fileprivate func setupMenuBar() {
        menuBar.setView(view: navigationController!)
        menuBar.setCurrentPos(currentPos: 0)
        view.addSubview(menuBar)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: menuBar)
        view.addConstraintsWithFormat(format: "V:|[v0(50)]", views: menuBar)
    }
    
    func setupSearchButton() {
        let searchButtonImg = UIImage(named: "search_icon")?.withRenderingMode(.alwaysOriginal)
        let searchBarButtonItem = UIBarButtonItem(image: searchButtonImg, style: .plain, target: self, action: #selector(searchFunc))
        
        navigationItem.rightBarButtonItems = [searchBarButtonItem]
    }
    
    func searchFunc() {
        print("Search")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "search") as! SearchViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.hidesBackButton = true
//        self.navigationItem.setHidesBackButton(true, animated:true)
        //        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.navigationItem.hidesBackButton = false
//        self.navigationItem.setHidesBackButton(false, animated:true)
        //        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //map.mapView.clear()
        map.locationManager.startUpdatingLocation()
        locationManager.startUpdatingLocation()
        betsLoaded = false
        bets = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showSelectedBet(bet: Bet){
        self.selectedBet = bet
        if (bet.userIsMediator == true) {
            performSegue(withIdentifier: "mapToEditBet", sender: self)
        }
        else {
            performSegue(withIdentifier: "mapToBetView", sender: self)
        }
    }
    
    func createBetAtLocation() {
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "mapToBetView")
        {
            let vc = segue.destination as! ViewBetViewController
            vc.reloadMap = false
            vc.bet = self.selectedBet
        }
        else if (segue.identifier == "mapToEditBet") {
            let vc = segue.destination as! MediatorViewController
            vc.bet = self.selectedBet
        }
    }

    @IBAction func toggleView(_ sender: AnyObject) {
        if (showMap == true) {
            self.mapView.isHidden = true
            self.listView.isHidden = false
            self.listView.reloadData()
            self.toggleViewButton.setTitle("Map View", for: .normal)
        }
        else {
            self.mapView.isHidden = false
            self.listView.isHidden = true
            self.toggleViewButton.setTitle("List View", for: .normal)
        }
        showMap = !showMap
    }

    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bets.count // your number of cell here
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:BetListCell = tableView.dequeueReusableCell(withIdentifier: "listViewCell", for: indexPath) as! BetListCell
        let bet = self.bets[indexPath.row]
        let potText = String(bet.pot)
        let userLocation = CLLocation(latitude: lat, longitude: long)
        let betLocation = CLLocation(latitude: bet.lat, longitude: bet.long)
        let distance = userLocation.distance(from: betLocation) / 1609
        let distanceText = String(format: "%.2f", distance) + " miles"
        
        //decides which image to display on the cell
        if (bet.pot < 50){
            cell.coinImageView.image = UIImage(named: "coin2")
        }
        else if(bet.pot < 400){
            cell.coinImageView.image = UIImage(named: "SmallStackCoins")
        }
        else{
            cell.coinImageView.image = UIImage(named: "StackedCoins")
        }
        cell.title?.text = bet.title
        cell.pot?.text = potText
        cell.distance?.text = distanceText
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 100.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        self.selectedBet = self.bets[indexPath.row]
        if (self.selectedBet.userIsMediator == true) {
            performSegue(withIdentifier: "mapToEditBet", sender: self)
        }
        else {
            performSegue(withIdentifier: "mapToBetView", sender: self)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        long = userLocation.coordinate.longitude;
        lat = userLocation.coordinate.latitude;
        prepareList()
        self.listView.reloadData()
        self.locationManager.stopUpdatingLocation()
    }
    
    func prepareList(){
        let user = User(id: User.currentUser())
        user.betsWithinVicinity(latParm: self.lat, longParm: self.long, radMiles: radius, completion: {
            bets in
            if (self.betsLoaded == true){
                self.bets.sort(by: { self.distanceFromUser(bet: $0) < self.distanceFromUser(bet: $1) })
                self.listView.reloadData()
                return
            }
            else {
                for bet in bets {
                    self.bets.append(bet)
                }
                self.bets.sort(by: { self.distanceFromUser(bet: $0) < self.distanceFromUser(bet: $1) })
                self.betsLoaded = true
            }
        })
    }
    
    func distanceFromUser(bet: Bet) -> Float{
        let userLocation = CLLocation(latitude: lat, longitude: long)
        let betLocation = CLLocation(latitude: bet.lat, longitude: bet.long)
        let distance = Float(userLocation.distance(from: betLocation) / 1609)
        return distance
    }

}
