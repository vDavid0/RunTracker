//
//  WhileTrainingViewController.swift
//  RunTracker
//
//  Created by Dávid Váradi on 2022. 11. 30..
//

import UIKit
import CoreMotion
import CoreLocation
import MapKit

class WhileTrainingViewController: UIViewController {
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    //Lepesszamlalo
    let pedoMeter = CMPedometer()
    
    //Sebesség, helyzet
    let locationManager = CLLocationManager()
    
    //Stopper
    var timer: Timer = Timer()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var training: Training?
    
    var minAltitude: Double?
    var maxAltitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //új edzés, koordináták létrehozása
        training = Training(context: context)
        training?.coordinates = Coordinates(context: context)
        training?.coordinates?.latitudes = []
        training?.coordinates?.longitudes = []
        
        training?.startDate = Date()
        
        //Stopper
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        
        //Sebesség, helyzet
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        setPedometer()
        configureFinishButton()
        
        mapView.showsUserLocation = true
        
        navigationItem.hidesBackButton = true
    }
    
    //Stopper
    @objc func timerCounter() {
        let currentDate = Date()
        let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: training?.startDate ?? Date(), to: currentDate)
        
        //ha egy szam kisebb mint 10 akkor is 2 jegyukent jelenjen meg
        var hours: String = String(diffComponents.hour!)
        var minutes: String = String(diffComponents.minute!)
        var seconds: String = String(diffComponents.second!)
        
        if diffComponents.hour! < 10 {
            hours = "0\(hours)"
        }
        if diffComponents.minute! < 10 {
            minutes = "0\(minutes)"
        }
        if diffComponents.second! < 10 {
            seconds = "0\(seconds)"
        }
        
        if diffComponents.hour == 0 {
            timeLabel.text = "\(minutes) : \(seconds)"
        } else {
            timeLabel.text = "\(hours) : \(minutes) : \(seconds)"
        }
    }
    
    //Lepesszamlalo
    func setPedometer() {
        if CMPedometer.isStepCountingAvailable() {
            self.pedoMeter.startUpdates(from: Date()) { [weak self] data, error  in
                guard error == nil else{return}
                if let response = data {
                    DispatchQueue.main.async {
                        self?.stepsLabel.text = "Steps: \(response.numberOfSteps)"
                        self?.distanceLabel.text = "Meters: \(response.distance?.uint64Value ?? 0)"
                        
                        self?.training?.steps = response.numberOfSteps as? Int64 ?? 0
                        self?.training?.distance = response.distance as? Double ?? 0
                    }
                }
            }
        }
    }
    
    func configureFinishButton() {
        finishButton.configuration?.attributedTitle?.font =  UIFont(name: "Helvetica", size: 50)
        finishButton.configuration?.titleAlignment = .center
        
        finishButton.configuration?.baseForegroundColor = .white
        finishButton.layer.cornerRadius = 15
        finishButton.backgroundColor = .secondaryLabel
    }
    
    //minimum és maximum magasság kigyűjtése
    func setAltitudes(at location: CLLocation) {
        guard minAltitude != nil && maxAltitude != nil else {
            minAltitude = location.altitude
            maxAltitude = location.altitude
            return
        }
        
        if location.altitude < minAltitude! {
            minAltitude = location.altitude
        }
        if location.altitude > maxAltitude! {
            maxAltitude = location.altitude
        }
    }
    
    func setMaxSpeed(current speed: Double) {
        if speed > training?.maxSpeed ?? 0 {
            training!.maxSpeed = speed
        }
    }
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
        locationManager.stopUpdatingLocation()
        pedoMeter.stopUpdates()
        
        //nincs engedelyezve a helymeghatarozas
        if minAltitude == nil || maxAltitude == nil {
            minAltitude = 0
            maxAltitude = 0
        }
        
        training?.endDate = Date()
        training?.altitudeDifference = round((maxAltitude! - minAltitude!) * 100) / 100.0
        training?.distance = round(training!.distance) / 1000 //km
                        
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer.invalidate()
        
        self.tabBarController?.tabBar.isHidden = false
        tabBarController?.selectedIndex = 1 //edzesek tableview-jára ugras
    }
}

extension WhileTrainingViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            locationManager.distanceFilter = 1 //1 meterenkent kuld uj adatokat
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.activityType = .fitness
            locationManager.showsBackgroundLocationIndicator = true
            locationManager.allowsBackgroundLocationUpdates = true
            
            locationManager.startUpdatingLocation()
        }
    }
    
    //Sebesség, lokáció
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {return}
        
        if location.horizontalAccuracy > 0 {
            //a telefon sebessege 2 tizedesjegyre kerekitve, m/s-ből km/h
            let roundedSpeed = round(location.speed * 3.6 * 100) / 100.0
            
            if  location.speed > 0 {
                speedLabel.text = "\(roundedSpeed) km/h"
            } else {
                speedLabel.text = "0 km/h"
            }
            
            training?.coordinates?.longitudes?.append(location.coordinate.longitude)
            training?.coordinates?.latitudes?.append(location.coordinate.latitude)
            
            setAltitudes(at: location)
            setMaxSpeed(current: roundedSpeed)
            
            //map frissitese lokacio szerint
            let locationCoordinate2D = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let zoomRegion = MKCoordinateRegion(center: locationCoordinate2D, latitudinalMeters: 1000, longitudinalMeters:  1000)
            mapView.setRegion(zoomRegion, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
