//
//  LocationService.swift
//  Weather1
//

import Foundation
import CoreLocation

enum LocationServiceError: Error {
    case locationServicesDisabled
    case invalidAuthorizationStatus(_ status: CLAuthorizationStatus)
    case locationUpdateError
    case locationManagerFailedWith(error: Error)
    
    var description: String {
        switch self {
        case .locationServicesDisabled:
            return "Device location services are disabled."
        case .invalidAuthorizationStatus(let status):
            return "Expected location manager authorizedWhenInUse authorization status, received \(status)."
        case .locationUpdateError:
            return "Update location returned error."
        case .locationManagerFailedWith(let error):
            return "Location manager failed, with error: \(error)."
        }
    }
}

protocol LocationService: AnyObject {
    var delegate: LocationServiceDelegate? { get set }
    
    func requestAuthorization()
    func isAuthorized() -> Bool
}

protocol LocationServiceDelegate: AnyObject {
    func locationServiceDidUpdate(_ location: CLLocation)
    func locationService(failedWithError error: LocationServiceError)
}

final class DeviceLocationService: NSObject, LocationService, CLLocationManagerDelegate {
    weak var delegate: LocationServiceDelegate?
    private var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func isAuthorized() -> Bool {
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            return true
        default:
            return false
        }
    }
    
    func requestAuthorization() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            delegate?.locationService(failedWithError: .invalidAuthorizationStatus(status))
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            locationManager.requestLocation()
        @unknown default:
            delegate?.locationService(failedWithError: .invalidAuthorizationStatus(status))
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways, .authorized:
            locationManager.requestLocation()
        default:
            delegate?.locationService(failedWithError: .invalidAuthorizationStatus(status))
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            delegate?.locationService(failedWithError: .locationUpdateError)
            return
        }
        
        delegate?.locationServiceDidUpdate(location)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        delegate?.locationService(failedWithError: .locationManagerFailedWith(error: error))
    }
}
