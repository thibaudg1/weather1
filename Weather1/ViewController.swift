//
//  ViewController.swift
//  Weather1
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var background: UIImageView!
    @IBOutlet var city: UILabel!
    @IBOutlet var icon: UIImageView!
    @IBOutlet var temperature: UILabel!
    
    private let weatherAPI = OpenWeatherAPIService()
    
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
        
        weatherAPI.fetchCurrentWeather(coordinate: rigaCoordinate) { weatherApiResust in
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
    
    func updateDisplayWith(_ weather: Weather) {
        self.icon.image = weather.icon.image
        self.temperature.text = weather.temperature
        self.city.text = weather.city
        self.descriptionLabel.text = weather.description
    }
}
