//
//  ViewController.swift
//  Weather1
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var background: UIImageView!
    @IBOutlet var city: UILabel!
    @IBOutlet var icon: UIImageView!
    @IBOutlet var temperature: UILabel!
    
    private let weatherAPI = OpenWeatherAPIService()
    private let locationService = DeviceLocationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        displayRigaCurrentWeather()
        
        background.layer.opacity = 0.85
    }


}

extension ViewController {
    func displayRigaCurrentWeather() {
        let rigaLat = 56.948889
        let rigaLon = 24.106389
        let rigaCoordinate = (rigaLat, rigaLon)
        
        fetchCurrentWeather(coordinate: rigaCoordinate)
    }
    
    func fetchCurrentWeather(coordinate: Coordinate) {
        weatherAPI.fetchCurrentWeather(coordinate: coordinate) { weatherApiResust in
            switch weatherApiResust {
            case .failure(let error):
                print(error)
                
            case .success(let currentWeather):
                let measurementFormatter = MeasurementFormatter()
                //measurementFormatter.unitOptions = .providedUnit
                measurementFormatter.numberFormatter.maximumFractionDigits = 1
                
                let measurement = Measurement(
                    value: currentWeather.main.temperature,
                    unit: UnitTemperature.kelvin
                )
                
                let tempCelsius = measurement.converted(to: .celsius)
                
                let weather = Weather(city: currentWeather.cityName,
                                      temperature: measurementFormatter.string(from: tempCelsius),
                                      description: currentWeather.weather.first!.description,
                                      icon: Weather.Icon.fog)
                
                DispatchQueue.main.async { [weak self] in
                    self?.updateDisplayWith(weather)
                }
            }
            
        }
    }
    
    func displayCurrentLocationWeather() {
        locationService.delegate = self
        locationService.requestAuthorization()
    }
    
    func updateDisplayWith(_ weather: Weather) {
        self.icon.image = weather.icon.image
        self.temperature.text = weather.temperature
        self.city.text = weather.city
        self.descriptionLabel.text = weather.description
    }
}

extension ViewController: LocationServiceDelegate {
    func locationServiceDidUpdate(_ location: CLLocation) {
        let coordinate: Coordinate = (location.coordinate.latitude,
                                      location.coordinate.longitude)
        
        fetchCurrentWeather(coordinate: coordinate)
    }
    
    func locationService(failedWithError error: LocationServiceError) {
        print(error.description)
    }
}
