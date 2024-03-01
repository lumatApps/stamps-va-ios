//
//  LocationManager.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import CoreLocation

@Observable class LocationManager: NSObject, CLLocationManagerDelegate {
    var location: CLLocation?
    var isAuthorized: Bool
    var authorizationStatus: CLAuthorizationStatus
    var city: String = ""
    var state: String = ""

    private let locationManager = CLLocationManager()

    override init() {
        isAuthorized = locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
            case .notDetermined, .restricted, .denied:
                isAuthorized = false
            case .authorizedAlways, .authorizedWhenInUse:
                isAuthorized = true
                locationManager.startUpdatingLocation()
            @unknown default:
                break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }

    func reverseGeocode(location: CLLocation) {
        // Reverse geocoding to get city and state
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                print("Error in reverse geocoding: \(error.localizedDescription)")
                return
            }

            guard let placemark = placemarks?.first else { return }
            self?.city = placemark.locality ?? "Unknown"
            self?.state = placemark.administrativeArea ?? "Unknown"
        }

    }
}
