//
//  ViewController.swift
//  Weather1
//

import UIKit
import CoreLocation
import Combine

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
    
    private var currentWeather: Weather = .riga
    private var temperatureUnit: TemperatureUnit = .celsius {
        didSet {
            if temperatureUnit == .celsius {
                temperature.text = currentWeather.tempCelsius
            } else {
                temperature.text = currentWeather.tempFahrenheit
            }
        }
    }
    
    private var query = PassthroughSubject<String, Never>()
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTempLabelTap()
        configureSearchController()
        configureCitySearch()
        update(with: .riga)
        //displayRigaCurrentWeather()
        //displayCurrentLocationWeather()
    }
    
    @IBAction func searchButton(_ sender: Any) {
        // Clear previous results and query
        resultsTableViewController.results = nil
        query.send("")
        
        // Display search results controller
        navigationItem.searchController?.isActive = true
        navigationItem.searchController?.searchBar.becomeFirstResponder()
        navigationItem.searchController?.searchBar.isHidden = false
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
        
        loadWeather(for: rigaCoordinate)
    }
    
    func loadWeather(for coordinate: Coordinate) {
        weatherAPI.loadWeather(for: coordinate)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error): print(error)
                default: break
                }
            } receiveValue: { [weak self] weather in
                self?.update(with: weather)
            }
            .store(in: &cancellable)
    }
    
    func loadWeather(for city: City) {
        weatherAPI.loadWeather(for: city)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error): print(error)
                default: break
                }
            } receiveValue: { [weak self] weather in
                self?.update(with: weather)
            }
            .store(in: &cancellable)
    }
    
    func displayCurrentLocationWeather() {
        locationService.delegate = self
        locationService.requestAuthorization()
    }
    
    func update(with weather: Weather) {
        currentWeather = weather
        
        self.temperature.text = (temperatureUnit == .celsius ? weather.tempCelsius : weather.tempFahrenheit)
        self.city.text = weather.location.name
        self.descriptionLabel.text = weather.current.description
        self.background.image = UIImage(named: weather.background)
        
        weatherAPI.fecthWeatherIcon(named: weather.current.icon) { imageResult in
            var uiImage: UIImage?
            
            switch imageResult {
            case .failure(let error):
                print("Error when fetching icon \(weather.current.icon): \(error)")
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
        
        loadWeather(for: coordinate)
    }
    
    func locationService(failedWithError error: LocationServiceError) {
        print(error.description)
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        print("User typed: >\(text)<")
        query.send(text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func configureCitySearch() {
        query
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .map { [weatherAPI] query in
                weatherAPI.fetchCityResults(forQuery: query)
                    .asResult()
            }
            .switchToLatest()
            .map { result -> [City] in
                switch result {
                case .success(let cities):
                    print("\(cities.count) city results")
                    return cities
                case .failure(let error):
                    print(error)
                    return []
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cities in
                guard !cities.isEmpty else { return }
                self?.resultsTableViewController.results = cities
            }
            .store(in: &cancellable)
    }
}

// MARK: - UISearchControllerDelegate
extension ViewController: UISearchControllerDelegate {
    func willDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.isHidden = true
    }
}

// MARK: - ResultsTableViewDelegate
extension ViewController: ResultsTableViewDelegate {
    func didSelect(city: City) {
        loadWeather(for: city)
        print("User selected city: \(city)")
        navigationItem.searchController?.isActive = false
    }
}
