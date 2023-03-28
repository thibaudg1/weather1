//
//  ViewController.swift
//  Weather1
//

import UIKit
import CoreLocation
import Combine

class ViewController: UIViewController {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var tempButton: UIButton!
    @IBOutlet var background: UIImageView!
    @IBOutlet var city: UILabel!
    @IBOutlet var icon: UIImageView!
    @IBOutlet var temperature: UILabel!
    @IBOutlet var userLocationButton: UIButton!
    
    private var resultsTableViewController: ResultsTableViewController!
    
    private let weatherAPI = OpenWeatherAPIService()
    private let locationService = DeviceLocationService()
    
    private var currentWeather: Weather = .riga
    private var temperatureUnit: TemperatureUnit? {
        didSet {
            if temperatureUnit == .celsius {
                temperature.text = currentWeather.tempCelsius
            } else {
                temperature.text = currentWeather.tempFahrenheit
            }
        }
    }
    private var language = "en" {
        didSet {
            weatherAPI.language = language
            resultsTableViewController.language = language
        }
    }
    
    private var query = PassthroughSubject<String, Never>()
    private var citySearchCancellable: AnyCancellable?
    private var weatherCancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTempLabelTap()
        configureSearchController()
        configureCitySearch()
        configureLanguage()
        update(with: .riga)
        //displayRigaCurrentWeather()
        //displayCurrentLocationWeather()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureFirstWeather()
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
    
    @IBAction func temperatureButtonTapped(_ sender: Any) {
        changeTempUnit()
    }
    
    @objc func temperatureTapped(_ sender: UITapGestureRecognizer) {
        changeTempUnit()
    }
    
    func changeTempUnit() {
        temperatureUnit = (temperatureUnit == .fahrenheit ? .celsius : .fahrenheit)
    }
    
    @IBAction func currentLocationTapped(_ sender: Any) {
        displayCurrentLocationWeather()
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
    
    func configureLanguage() {
        guard let languageSub = Locale.preferredLanguages.first?.prefix(2) else { return }
        language = String(languageSub)
#if DEBUG
print(language)
#endif
    }
    
    func configureFirstWeather() {
        // Load (Riga, LV) weather by default when launching the app:
        displayRigaCurrentWeather()
        
        // Then try to load weather for current location:
        if locationService.isAuthorized() {
            displayCurrentLocationWeather()
        } else {
            // ask for access to user's location:
            let message = "What location would you like to show weather for?"
            let ac = UIAlertController(title: "Choose your location", message: message, preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "My current location", style: .default, handler: displayCurrentLocationWeather))
            
            // Fallback to default location's weather if user doesn't want to use her location:
            ac.addAction(UIAlertAction(title: "Riga, LV", style: .default))
            
            present(ac, animated: true)
        }
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
        cancelWeatherRequest()
        
        weatherCancellable = weatherAPI.loadWeather(for: coordinate)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error): print(error)
                default: break
                }
            } receiveValue: { [weak self] weather in
                self?.update(with: weather)
            }
    }
    
    func loadWeather(for city: City) {
        cancelWeatherRequest()
        
        weatherCancellable = weatherAPI.loadWeather(for: city)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error): print(error)
                default: break
                }
            } receiveValue: { [weak self] weather in
                self?.update(with: weather)
            }
    }
    
    private func cancelWeatherRequest() {
        weatherCancellable?.cancel()
        weatherCancellable = nil
    }
    
    func displayCurrentLocationWeather(_ action: UIAlertAction? = nil) {
        locationService.delegate = self
        locationService.requestAuthorization()
    }
    
    func update(with weather: Weather) {
        currentWeather = weather
        
        switch temperatureUnit {
        case .celsius: self.temperature.text = weather.tempCelsius
        case .fahrenheit : self.temperature.text = weather.tempFahrenheit
        default: self.temperature.text = weather.tempLocale
        }
        
        self.city.text = weather.location.localizedName(for: language)
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
        citySearchCancellable = query
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
