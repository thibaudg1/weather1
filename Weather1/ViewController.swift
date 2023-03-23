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
    
    private var resultsTableViewController: ResultsTableViewController!
    
    private let weatherAPI = OpenWeatherAPIService()
    private let locationService = DeviceLocationService()
    
    private var currentWeather: Weather?
    private var temperatureUnit: TemperatureUnit = .fahrenheit {
        didSet {
            if temperatureUnit == .celsius {
                temperature.text = currentWeather?.tempCelsius
            } else {
                temperature.text = currentWeather?.tempFahrenheit
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTempLabelTap()
        configureSearchController()
        
        //displayRigaCurrentWeather()
        //displayCurrentLocationWeather()
        
        background.layer.opacity = 0.85
    }
    
    @IBAction func searchButton(_ sender: Any) {
        resultsTableViewController.results = nil
        navigationItem.searchController?.searchBar.isHidden = false
        //navigationItem.searchController?.isActive = true
        navigationItem.searchController?.searchBar.becomeFirstResponder()
    }
    
    @IBAction func currentLocationTapped(_ sender: Any) {
        displayCurrentLocationWeather()
    }
    
    @objc func temperatureTapped(_ sender: UITapGestureRecognizer) {
        temperatureUnit = (temperatureUnit == .celsius ? .fahrenheit : .celsius)
    }
    
    func setupTempLabelTap() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.temperatureTapped(_:)))
        self.temperature.isUserInteractionEnabled = true
        self.temperature.addGestureRecognizer(tapGR)
    }
    
    func configureSearchController() {
        resultsTableViewController = storyboard!.instantiateViewController(withIdentifier: "resultsViewController") as? ResultsTableViewController
        
        resultsTableViewController.delegate = self
        
        let searchController = UISearchController(searchResultsController: resultsTableViewController)
        searchController.showsSearchResultsController = true
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        //search.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Type a city, state and country"
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
                let weather = Weather(city: currentWeather.cityName,
                                      temperature: currentWeather.main.temperature,
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
        currentWeather = weather
        
        self.temperature.text = (temperatureUnit == .celsius ? weather.tempCelsius : weather.tempFahrenheit)
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
        guard let text = searchController.searchBar.text,
              !text.isEmpty  else { return }
        
        print("User typed: >\(text)<")
        
        weatherAPI.fetchGeocodedCities(search: text) { [weak self] cityResult in
            switch cityResult {
            case .failure(let error):
                print(error)
            case .success(let cities):
                guard !cities.isEmpty else { return }
                DispatchQueue.main.async {
                    self?.resultsTableViewController.results = cities
                }                
            }
        }
    }
}

// MARK: - UISearchControllerDelegate
extension ViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.isHidden = true
    }
}

// MARK: - ResultsTableViewDelegate
extension ViewController: ResultsTableViewDelegate {
    func didSelect(city: City) {
        let coordinate = (city.latitude, city.longitude)
        fetchCurrentWeather(coordinate: coordinate)
        print("User selected city: \(city)")
        navigationItem.searchController?.isActive = false
    }
}
