//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Nikita Gribin on 18.07.2021.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
    }

class MapViewController: UIViewController {
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place =  Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    var incomeSegueIdentifier = ""
    var placeCoordinate: CLLocationCoordinate2D?
    var directionsArray: [MKDirections] = []
    var previousLocation: CLLocation? {
        didSet {
            startTrackingLocation()
        }
        
        
    }
    
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var adressLabel: UILabel!
    @IBOutlet var pinMap: UIImageView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
        adressLabel.text = ""
    }
    
    @IBAction func actionDone() {
        mapViewControllerDelegate?.getAddress(adressLabel.text)
        dismiss(animated: true)
    }
  
    @IBAction func centrUserLocation() {
        showUserAdress()
    }
    
    @IBAction func goButtonPressed() {
        getDirections()
    }
    
    
    @IBAction func cloceVC() {
        dismiss(animated: true)
    }
    private func setupMapView() {
        
        goButton.isHidden = true
        
        if incomeSegueIdentifier == "showMap" {
            setupPlacemark()
            pinMap.isHidden = true
            adressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
    
    private func resetMapView(withNew directions: MKDirections) {
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    private func setupPlacemark() {
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) {(plasemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = plasemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
        
        
        
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showAlert(
                title: "Location Services are Disabled",
                message: "To enable it go: Settings -> Privacy -> Location Services and turn On"
            )
        }
            
        }
    }
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
   private func checkLocationAuthorization() {
    var status : CLAuthorizationStatus {
        if #available(iOS 14.0, *) { return CLLocationManager().authorizationStatus
            
        } else { return CLLocationManager.authorizationStatus()
            
        }
    }
    switch status {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAdress" { showUserAdress() }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Your Location is not Available",
                    message: "To give permission Go to: Setting -> MyPlaces -> Location"
                )
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
        break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is avalable")
        
    }
    
   
   
   }
    
    private func getUserCentr(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
        
    }
    
    private func showAlert(title: String, message: String) {
        
        let alertSheer = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alertSheer.addAction(okAction)
        present(alertSheer, animated: true, completion: nil)
        
        
    }
    
    private func showUserAdress() {
        
        if let location = locationManager.location?.coordinate {
        let region = MKCoordinateRegion(center: location,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func startTrackingLocation() {
        guard  let previousLocation = previousLocation else { return }
        let center = getUserCentr(for: mapView)
        
        guard center.distance(from: previousLocation) > 50  else { return }
        self.previousLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserAdress()
        }
        
    }
    
    
    
    
    private func getDirections() {
        guard  let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        
        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { (response, error) in
            if  let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.showAlert(title: "Error", message: "Directions is not available")
                return
            }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места: \(distance) км.")
                print("Время в пути составит: \(timeInterval) сек.")
            }
        
        }
    }
    
        
    private func createDirectionsRequest(from coordinate:CLLocationCoordinate2D) -> MKDirections.Request? {
        guard  let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
       return request
    }
}


extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        

        if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                imageView.layer.cornerRadius = 10
                imageView.clipsToBounds = true
                imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
            
        }
    
   
        
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let centr = getUserCentr(for: mapView)
        let geoCoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showMap" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showUserAdress()
            }
        }
        geoCoder.cancelGeocode()
        
        geoCoder.reverseGeocodeLocation(centr) { placemarks, error in
             
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let builtNamber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && builtNamber != nil {
                    self.adressLabel.text = "\(streetName!),\(builtNamber!)"
                } else if  streetName != nil {
                    self.adressLabel.text = "\(streetName!)"
                } else {
                    self.adressLabel.text = ""
                }
            }
 
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
}


extension MapViewController: CLLocationManagerDelegate {
    
   func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      checkLocationAuthorization()
    
   }
    
    
    
    
    
}
