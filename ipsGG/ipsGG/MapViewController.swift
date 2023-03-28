//
//  MapViewController.swift
//  ipsGG
//
//  Created by Dương Sơn on 3/19/19.
//  Copyright © 2019 Dương Sơn. All rights reserved.
//

import UIKit
import GoogleMaps
import GameplayKit
import simd

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    // Step Service
    var heading : Double = 0.0
    var stepLength = 0.6
    var stepCount = 0
//    let stepService = StepService()
    // Initial Map View
    let myGraph = GKGraph()
    var Start = myNode(name: "", pos: (x: 0, y: 0), layer: 1)
    var Destination = myNode(name: "", pos: (x: 0, y: 0), layer: 1)
    var curLocation = myNode(name: "", pos: (x: 0, y: 0), layer: 1)
    //    var latitude_0: Double = 21.0379635 //latitude corresponding to x = 0
    //    var longitude_0: Double = 105.783293 //longitude corresponding to y = 0
    var latitude_0: Double = 21.037966 //latitude corresponding to x = 0
    var longitude_0: Double = 105.783140 //longitude corresponding to y = 0
    var latitude: Double = 0 //latitude corresponding to x
    var longitude: Double = 0 //longitude corresponding to y
    var mapView: GMSMapView? //MAP VIEW OBJECT
    var floor : Int = 0
    // iBeacon-Location Service
    let locationManager : CLLocationManager = CLLocationManager()
    var region = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "7df793a819bf2b12127e803a6f33f91c")
    var beacons : [CLBeacon] = []
    var isDrawDestination: Bool = false
    var isDrawGMSMakerCurrent: Bool = false
    var isShowCurrentLocation: Bool = false
    var currentMarker: GMSMarker?
    var currentPolyline: GMSPolyline?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Step Service
        //        stepService.delegate = self
        //        stepService.startStepCount(fps: 60)
        
        // Location Service
        //        var myLocation = ;
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingHeading()
        locationManager.startRangingBeacons(in: region)
        
        initMap()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        self.navigationController?.navigationBar.backgroundColor = .clear
//    }
    
    func setUp() {
        guard !isDrawDestination else {
            return
        }
        print("Setup")
        // From-To Decision
        switch Start.name {
        case "Your current location": Start = curLocation
            //            isShowCurrentLocation = true
        case "Room 101": Start = r_101
        case "Room 102": Start = r_102
        case "Room 103": Start = r_103
        case "Room 106": Start = r_106
        case "Room 107": Start = r_107
        case "Computer Center": Start = com_cen
        case "Entrance": Start = entrance
//        case "Entrance B": Start = entrance_B
//        case "Entrance C": Start = entrance_C
        case "Men WC": Start = mwc
        case "Women WC": Start = wwc
            //        case "Room 201": Start = r_201
            //        case "Room 202": Start = r_202
            //        case "Room 203": Start = r_203
            //        case "Room 204": Start = r_204
            //        case "Room 205": Start = r_205
            //        case "Room 206": Start = r_206
            //        case "Room 206a": Start = r_206a
            //        case "Room 207": Start = r_207
            //        case "Room 208": Start = r_208
            //        case "Room 209": Start = r_209
            //        case "Room 210": Start = r_210
            //        case "Room 202G2b": Start = r_202g2b
        default:
            print("Error")
        }
        switch Destination.name {
        case "Your current location" : Destination = curLocation
        case "Room 101": Destination = r_101
        case "Room 102": Destination = r_102
        case "Room 103": Destination = r_103
        case "Room 106": Destination = r_106
        case "Room 107": Destination = r_107
        case "Computer Center": Destination = com_cen
        case "Entrance": Destination = entrance
//        case "Entrance B": Destination = entrance_B
//        case "Entrance C": Destination = entrance_C
        case "Men WC": Destination = mwc
        case "Women WC": Destination = wwc
            //        case "Room 201": Destination = r_201
            //        case "Room 202": Destination = r_202
            //        case "Room 203": Destination = r_203
            //        case "Room 204": Destination = r_204
            //        case "Room` `205": Destination = r_205
            //        case "Room 206": Destination = r_206
            //        case "Room 206a": Destination = r_206a
            //        case "Room 207": Destination = r_207
            //        case "Room 208": Destination = r_208
            //        case "Room 209": Destination = r_209
            //        case "Room 210": Destination = r_210
            //        case "Room 202G2b": Destination = r_202g2b
        default:
            print("Error")
        }
        
        if (Start == Destination) {
            AlertHelper.showAlert(message: "Bạn đã tới nơi!", from: self) {
                [weak self] in guard let self = self else {return}
                if let navi = self.navigationController {
                    navi.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true)
                }
            }
            return
        }
        
        drawGMSMarker(Node: Destination, title_name: "To: \(Destination.name)", tag: "destination")
        
        if (!isShowCurrentLocation) {
            drawGMSMarker(Node: Start, title_name: "From: \(Start.name)", tag: "start")
            drawPolyline(node_start: Start, node_destination: Destination)
        }
    }
    
    func initMap() {
        
        // Map view initialize
        let initialLocation = CLLocationCoordinate2DMake(21.038070, 105.783379)
        let camera = GMSCameraPosition.camera(withTarget: initialLocation, zoom: 20)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.view = mapView
        
        // Adding indoor map
        let southwest = CLLocationCoordinate2DMake(21.037946, 105.783623)
        let northeast = CLLocationCoordinate2DMake(21.038200, 105.783141)
        let overlayBound = GMSCoordinateBounds(coordinate: southwest, coordinate: northeast)
        let indoorMapImage = UIImage(named: "1st floor.png")!
        let rotatedImage = indoorMapImage.rotate(radians: 0.01745329252)
        let indoorMapOverlay = GMSGroundOverlay(bounds: overlayBound, icon: rotatedImage)
        indoorMapOverlay.bearing = 0
        indoorMapOverlay.map = mapView
        
        // Adding pin points for start and destination point
        let from: GMSMarker = GMSMarker(position: convert(x: Start.pos.x, y: Start.pos.y))
        from.icon = GMSMarker.markerImage(with: .red)
        from.title = "From: \(Start.name)"
        // from.opacity = 0
        from.snippet = "From: \(Start.name)"
        from.map = mapView
        let to: GMSMarker = GMSMarker(position: convert(x: Destination.pos.x, y: Destination.pos.y))
        to.icon = GMSMarker.markerImage(with: .blue)
        to.title = "To: \(Destination.name)"
        to.snippet = "To: \(Destination.name)"
        to.map = mapView
        //        mapView?.isMyLocationEnabled = true
        
        // GRAPH AND NODE CONNECTION
        myGraph.add([r_101, r_102, r_103, r_106, r_107, entrance, wwc, mwc, com_cen, n1, n2, n3, n4, n5, n6, n7, n8, n9])
        entrance.addConnection(to: n1, bidirectional: true, weight: distance(Node1: entrance, Node2: n1))
        entrance.addConnection(to: n2, bidirectional: true, weight: distance(Node1: entrance, Node2: n2))
        entrance.addConnection(to: n3, bidirectional: true, weight: distance(Node1: entrance, Node2: n3))
        n1.addConnection(to: r_101, bidirectional: true, weight: distance(Node1: n1, Node2: r_101))
        n1.addConnection(to: n2, bidirectional: true, weight: distance(Node1: n1, Node2: n2))
        n1.addConnection(to: n4, bidirectional: true, weight: distance(Node1: n1, Node2: n4))
        n2.addConnection(to: n4, bidirectional: true, weight: distance(Node1: n2, Node2: n4))
        n2.addConnection(to: n5, bidirectional: true, weight: distance(Node1: n2, Node2: n5))
        n2.addConnection(to: n3, bidirectional: true, weight: distance(Node1: n2, Node2: n3))
        n3.addConnection(to: n5, bidirectional: true, weight: distance(Node1: n3, Node2: n5))
        n3.addConnection(to: r_107, bidirectional: true, weight: distance(Node1: n3, Node2: r_107))
        r_101.addConnection(to: n4, bidirectional: true, weight: distance(Node1: r_101, Node2: n4))
        r_107.addConnection(to: n5, bidirectional: true, weight: distance(Node1: r_107, Node2: n5))
        n4.addConnection(to: wwc, bidirectional: true, weight: distance(Node1: n4, Node2: wwc))
        n4.addConnection(to: r_102, bidirectional: true, weight: distance(Node1: n4, Node2: r_102))
        n4.addConnection(to: n6, bidirectional: true, weight: distance(Node1: n4, Node2: n6))
        n4.addConnection(to: n7, bidirectional: true, weight: distance(Node1: n4, Node2: n7))
        n5.addConnection(to: n8, bidirectional: true, weight: distance(Node1: n5, Node2: n8))
        n5.addConnection(to: r_106, bidirectional: true, weight: distance(Node1: n6, Node2: r_106))
        n5.addConnection(to: mwc, bidirectional: true, weight: distance(Node1: n5, Node2: mwc))
        wwc.addConnection(to: r_102, bidirectional: true, weight: distance(Node1: wwc, Node2: r_102))
        wwc.addConnection(to: n6, bidirectional: true, weight: distance(Node1: wwc, Node2: n6))
        mwc.addConnection(to: r_106, bidirectional: true, weight: distance(Node1: mwc, Node2: r_106))
        r_102.addConnection(to: r_103, bidirectional: true, weight: distance(Node1: r_102, Node2: r_103))
        r_102.addConnection(to: n6, bidirectional: true, weight: distance(Node1: r_102, Node2: n6))
        n6.addConnection(to: n9, bidirectional: true, weight: distance(Node1: n6, Node2: n9))
        n9.addConnection(to: com_cen, bidirectional: true, weight: distance(Node1: n9, Node2: com_cen))
        n7.addConnection(to: n8, bidirectional: true, weight: distance(Node1: n7, Node2: n8))
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        let knowsBeacon = beacons.filter{$0.rssi != 0}
//        self.beacons = knowsBeacon
//        if knowsBeacon[0].major == 150 {
//            curLocation = entrance
//        } else {
//            curLocation = mwc
//        }
//    }
        
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let knowsBeacon = beacons.filter{$0.rssi != 0}
        self.beacons = knowsBeacon
        
        let beacon0 = knowsBeacon[0]
        let beacon1 = knowsBeacon[1]
        let beacon2 = knowsBeacon[2]
        	
        var offlinePhase = [Double](repeating: 0, count: 20)
        
        var resultArray = [Double](repeating: 0, count: 20)
        
        
        var x = 2
        var id = 0
        var curLoca = 0
        
        for i in 1...20 {
            var tempSum: Double = 0;
            for j in 0...2 {
                tempSum += abs(Double(knowsBeacon[j].rssi)-offlinePhase[i])
            }
            resultArray[i] = tempSum;
            tempSum = 0;
        }
        
        var minValue: Double = resultArray[0];
        
        for i in 1...20 {
            if (minValue > resultArray[i]) {
                minValue = resultArray[i]
                id = i
            }
        }
        
        if (id % x == 0) {
            curLoca = id / x
        } else {
            curLoca = (id / x) + 1
        }
        
        setUp()
        if (isShowCurrentLocation) {
            currentMarker?.map = nil
            
            let marker: GMSMarker = GMS
            
            Marker(position: convert(x: curLocation.pos.x, y: curLocation.pos.y))
            marker.title = "Your current location: \(curLocation.name)"
            marker.icon = GMSMarker.markerImage(with: .systemBlue)
            marker.map = mapView
            currentMarker = marker
            
//            drawGMSMarker(Node: curLocation, title_name: "Your current location: \(temp_node.name)", tag: "current")
            
            if (curLocation == Destination) {
                AlertHelper.showAlert(message: "Bạn đã tới nơi!", from: self) {
                    [weak self] in guard let self = self else {return}
                    if let navi = self.navigationController {
                        navi.popViewController(animated: true)
                    } else {
                        self.dismiss(animated: true)
                    }
                }
                return
            }
            
            drawPolyline(node_start: curLocation, node_destination: Destination)
        }
        isDrawDestination = true
        
         
        
//        let knowsBeacon = beacons.filter{$0.rssi != 0}
//        self.beacons = knowsBeacon
//        // Decision Current Position
//        if knowsBeacon[0].major == 60122{
//            curLocation = n6
//        } else{
//            curLocation = com_cen
//        }
//
//        // Draw Marker for Current Position
//        let curMarker: GMSMarker = GMSMarker(position: convert(x: curLocation.pos.x, y: curLocation.pos.y))
//        //curMarker.icon = UIImage(named: "curLocation")?.withRenderingMode(.alwaysTemplate)
////        let curArr = UIImage(named: "arrow.png")
////        let curArrow = curArr!.rotate(radians: CGFloat(heading*(Double.pi/180)))
////        curMarker.icon = curArrow
//        curMarker.icon = GMSMarker.markerImage(with: .black)
//        curMarker.title = "Current Location: \(curLocation.name)"
//
//        if (curLocation != Start) && (curLocation != Destination){
//            curMarker.map = mapView
//            let path2 = GMSMutablePath()
//            let nodePath2 = myGraph.findPath(from: curLocation, to: Destination)
//            let xxx = pX(nodePath2)
//            let yyy = pY(nodePath2)
//            for i in 0...xxx.count - 2{
//                path2.add(convert(x: Double(xxx[i]), y: Double(yyy[i])))
//                path2.add(convert(x: Double(xxx[i+1]), y: Double(yyy[i+1])))
//            }
//            let polyline2 = GMSPolyline(path: path2)
//            polyline2.geodesic = true
//            polyline2.strokeColor = .blue
//            polyline2.spans = [GMSStyleSpan(color: .red, segments: 2)]
//            polyline2.map = mapView
//            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
//                polyline2.map = nil
//                curMarker.map = nil
//            }
//        }
//        else{
//            curMarker.map = mapView
//            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
//                curMarker.map = nil
//            }
//        }
    }
        
    func convert(x: Double, y: Double) -> CLLocationCoordinate2D{
        //Converting (x, y) to (latitude, longitude)
        latitude = latitude_0 + 0.18 * pow(10, -4) * (x * cos(0.01745329252) - y * sin(0.01745329252))
        longitude = longitude_0 + 0.1975 * pow(10, -4) * (y * cos(0.01745329252) + x * sin(0.01745329252))
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func distance(Node1: myNode, Node2: myNode) -> Float{
        //Return (weight) distance between 2 points
        let d: Double = sqrt((Node1.pos.x-Node2.pos.x)*(Node1.pos.x-Node2.pos.x) + (Node1.pos.y-Node2.pos.y)*(Node1.pos.y-Node2.pos.y))
        return Float(d)
    }
    
//    func step() {
//        var isMoving = 0{
//            didSet{
//                latitude_0 = latitude_0 + (stepLength) * 0.18 * pow(10, -4) * cos(heading*(Double.pi/180))
//                longitude_0 = longitude_0 + (stepLength) * 0.1975 * pow(10, -4) * sin(heading*(Double.pi/180))
//            }
//        }
//        drawCircle(centerOn: CLLocationCoordinate2D(latitude: latitude_0, longitude: longitude_0))
//        isMoving  += 1
//        stepCount += 1
//    }
    
    func drawCircle(centerOn coordinate: CLLocationCoordinate2D) {
        let circle = GMSCircle(position: coordinate, radius: 0.25)
        circle.fillColor = UIColor.red.withAlphaComponent(0.0)
        circle.strokeColor = .red
        circle.strokeWidth = 1
        circle.map = mapView
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
            circle.map = nil
        }
    }
    
//    func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
//        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
//        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return newImage
//    }
    
    func drawGMSMarker(Node: myNode, title_name: String, tag: String) {
        let marker: GMSMarker = GMSMarker(position: convert(x: Node.pos.x, y: Node.pos.y))
        
        if (tag == "start") {
            marker.icon = GMSMarker.markerImage(with: .systemBlue)
        }
        
        if (tag == "destination") {
            marker.icon = GMSMarker.markerImage(with: .systemRed)
        }
        
        if (tag == "current") {
            marker.icon = GMSMarker.markerImage(with: .systemYellow)
        }
    }

    func drawPolyline(node_start: myNode, node_destination: myNode) {
        currentPolyline?.map = nil
        // Find shortest path then draw
        let path = GMSMutablePath()
        let nodePath = myGraph.findPath(from: Start, to: Destination)
        let xx = pX(nodePath)
        let yy = pY(nodePath)
        for i in 0...xx.count - 2{
            path.add(convert(x: Double(xx[i]), y: Double(yy[i])))
            path.add(convert(x: Double(xx[i+1]), y: Double(yy[i+1])))
        }
        let polyline = GMSPolyline(path: path)
        polyline.geodesic = true
        polyline.strokeColor = .blue
        polyline.spans = [GMSStyleSpan(color: .red, segments: 2)]
        //        polyline.map = mapView
        currentPolyline = polyline
        currentPolyline?.map = mapView
    }
    
    func locationBeacon(major: NSNumber) -> (Double, Double) {
        switch(major) {
        case 20: return (0, 1)
        case 160: return (0, 5)
        case 220: return (0, 10)
        default: return (0, 0)
        }
    }
    //        print(nodePath)
    //        printCost(for: nodePath)
//    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
//        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
//        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        return newImage
//    }
}
