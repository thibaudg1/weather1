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
    
    @IBOutlet var userLocationButton: UIButton!
    
    private let weatherAPI = OpenWeatherAPIService()
    private let locationService = DeviceLocationService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureSearchController()
        
        displayRigaCurrentWeather()
        //displayCurrentLocationWeather()
        
        background.layer.opacity = 0.85
    }
    
    @IBAction func searchButton(_ sender: Any) {
        navigationItem.searchController?.searchBar.isHidden = false
        //navigationItem.searchController?.isActive = true
        navigationItem.searchController?.searchBar.becomeFirstResponder()
    }
    
    @IBAction func currentLocationTapped(_ sender: Any) {
        displayCurrentLocationWeather()
    }
    
    func configureSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        //search.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Type something here to search"
        searchController.searchBar.isHidden = true
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
                                      icon: currentWeather.weather.first!.icon,
                                      group: currentWeather.weather.first!.id)
                
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
        
        self.temperature.text = weather.temperature
        self.city.text = weather.city
        self.descriptionLabel.text = weather.description
        self.background.image = UIImage(named: weather.background)
        
        weatherAPI.fecthWeatherIcon(named: weather.icon) { imageResult in
            var uiImage: UIImage?
            
            switch imageResult {
            case .failure(let error):
                print("Error when fetching icon \(weather.icon): \(error)")
                return
            case .success(let imageData):
                uiImage = UIImage(data: imageData)
            }
            
            DispatchQueue.main.async {
                self.icon.image = uiImage
            }
        }
    }
}

// MARK: - LocationServiceDelegate
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

// MARK: - UISearchResultsUpdating Delegate
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print("Last typed: >\(text)<")
    }
}

// MARK: - UISearchControllerDelegate
extension ViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.isHidden = true
    }
}
