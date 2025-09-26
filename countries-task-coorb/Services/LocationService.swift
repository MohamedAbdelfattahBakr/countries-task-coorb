//
//  LocationService.swift
//  countries-task-coorb
//
//  Created by Mohamed Bakr on 25/09/2025.
//

import Foundation
import CoreLocation
import Combine

protocol LocationServiceProtocol {
    func requestLocation() -> AnyPublisher<String?, Error>
    var authorizationStatus: CLAuthorizationStatus { get }
}

class LocationService: NSObject, LocationServiceProtocol, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private var locationSubject = PassthroughSubject<String?, Error>()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocation() -> AnyPublisher<String?, Error> {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return locationSubject.eraseToAnyPublisher()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            return locationSubject.eraseToAnyPublisher()
        case .denied, .restricted:
            return Fail(error: LocationError.permissionDenied)
                .eraseToAnyPublisher()
        @unknown default:
            return Fail(error: LocationError.unknown)
                .eraseToAnyPublisher()
        }
    }
    
    private func getCountryFromLocation(_ location: CLLocation) {
        Task {
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                guard let placemark = placemarks.first,
                      let country = placemark.country else {
                    await MainActor.run {
                        self.locationSubject.send(completion: .failure(LocationError.noCountryFound))
                    }
                    return
                }
                
                await MainActor.run {
                    self.locationSubject.send(country)
                    self.locationSubject.send(completion: .finished)
                }
            } catch {
                await MainActor.run {
                    self.locationSubject.send(completion: .failure(error))
                }
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            locationSubject.send(completion: .failure(LocationError.noLocationFound))
            return
        }
        
        getCountryFromLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationSubject.send(completion: .failure(error))
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            locationSubject.send(completion: .failure(LocationError.permissionDenied))
        default:
            break
        }
    }
}

enum LocationError: Error, LocalizedError {
    case permissionDenied
    case noLocationFound
    case noCountryFound
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied"
        case .noLocationFound:
            return "Unable to find location"
        case .noCountryFound:
            return "Unable to determine country from location"
        case .unknown:
            return "Unknown location error"
        }
    }
}
