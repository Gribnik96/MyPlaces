//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Nikita Gribin on 18.07.2021.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    var place =  Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    var incomeSegueIdentifier = ""
    
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var adressLabel: UILabel!
    @IBOutlet var pinMap: UIImageView!
    @IBOutlet var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
        adressLabel.text = ""
    }
    
    @IBAction func actionDone() {
    }
    @IBAction func centerViewIsUserLocation() {
     showUserAdress()
    }
    
    
    @IBAction func cloceVC() {
        dismiss(animated: true)
    }
    private func setupMapView() {
        if incomeSegueIdentifier == "showMap" {
            setupPlacemark()
            pinMap.isHidden = true
            
        }
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
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
        
        
        
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            locationManagerDidChangeAuthorization()
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
    
   private func locationManagerDidChangeAuthorization() {
    switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAdress" {
                showUserAdress()
            }
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
                                        latitudinalMeters: 10000,
                                        longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
        }
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
}


extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManagerDidChangeAuthorization()
    }
    
    
    
    
    
}
