//
//  DetailsViewController.swift
//  RunTracker
//
//  Created by Dávid Váradi on 2022. 12. 02..
//

import UIKit
import MapKit


class DetailsViewController: UIViewController {
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    
    var training: Training? = nil
    var routeOverlay : MKOverlay?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        initLabels()
        addPins()
        drawRoute()
    }
    
    func initLabels() {
        stepsLabel.text = "\(training?.steps ?? 0)"
        distanceLabel.text = "\(training?.distance ?? 0)"
        
        //edzes idotartamanak kiszamitasa
        guard training?.startDate != nil && training?.endDate != nil else {return}
        let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: training!.startDate!, to: training!.endDate!)
        
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
        
        timeLabel.text = "\(hours):\(minutes):\(seconds)"
        
        //magassagvaltozas
        altitudeLabel.text = "\(training?.altitudeDifference ?? 0)"
        
        maxSpeedLabel.text = "\(training?.maxSpeed ?? 0.0)"
    }
    
    func addPins() {
        guard training?.coordinates?.longitudes != nil else {return}
        guard training?.coordinates?.latitudes != nil else {return}
        
        if training?.coordinates?.longitudes?.count != 0 {
            
            //start pin
            let startLatitude = training?.coordinates?.latitudes!.first ?? 47.0
            let startLongitude = training?.coordinates?.longitudes!.first ?? 19.0
            
            let startPin = MKPointAnnotation()
            startPin.title = "Start"
            startPin.coordinate = CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude)
            
            mapView.addAnnotation(startPin)
            
            //cél pin
            let finishLatitude = training?.coordinates?.latitudes!.last ?? 50.0
            let finishLongitude = training?.coordinates?.longitudes!.last ?? 19.0
            
            let finishPin = MKPointAnnotation()
            finishPin.title = "Finish"
            finishPin.coordinate = CLLocationCoordinate2D(latitude: finishLatitude, longitude: finishLongitude)
            
            mapView.addAnnotation(finishPin)
        }
    }
    
    func drawRoute() {
        guard let longitudes = training?.coordinates?.longitudes else {return}
        guard let latitudes = training?.coordinates?.latitudes else {return}
        
        guard !longitudes.isEmpty else {return}
        guard !latitudes.isEmpty else {return}
        
        //futás közben érintett koordináták kigyűjtése
        var coordinates = [CLLocationCoordinate2D]()
        for i in 0...(longitudes.count) - 1 {
            coordinates.append(CLLocationCoordinate2D(latitude: (latitudes[i]), longitude: (longitudes[i])))
        }
        
        DispatchQueue.main.async {
            self.routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
            self.mapView.addOverlay(self.routeOverlay!, level: .aboveRoads)
            self.mapView.setVisibleMapRect(self.routeOverlay!.boundingMapRect, animated: true)
        }
    }
}

extension DetailsViewController : MKMapViewDelegate {
    
    //Kirajzolt vonal miatt renderer beállítása
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKGradientPolylineRenderer(overlay: overlay)
        renderer.setColors([.green], locations: [])
        renderer.lineWidth = 4.0
        return renderer
    }
}
