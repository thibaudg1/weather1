//
//  APIService.swift
//  Weather1
//

import Foundation
import Combine

typealias Coordinate = (latitude: Double, longitude: Double)
typealias WeatherForecastCompletionBlock = (Result<CurrentWeatherResponse, APIServiceError>) -> Void
typealias ImageData = Data
typealias IconCompletionBlock = (Result<ImageData, APIServiceError>) -> Void
typealias CityResultsCompletionBlock = (Result<[City], APIServiceError>) -> Void

protocol APIService {
    func fetchCurrentWeather(coordinate: Coordinate,
                             completionHandler: @escaping WeatherForecastCompletionBlock)
    func fetchGeocodedCities(search: String,
                             completionHandler: @escaping CityResultsCompletionBlock)
    
    func fetchCityResults(forQuery query: String) -> AnyPublisher<[City], APIServiceError>
}

enum APIServiceError: Error {
    case invalidURL
    case emptyDataOrError
    case unexpectedStatusCode(_ statusCode: Int)
    case unableToParseDataWith(error: Error)
    
    var description: String {
        switch self {
        case .invalidURL:
            return "Failed to construct URL."
        case .emptyDataOrError:
            return "Request did not fetch data or returned error."
        case .unexpectedStatusCode(let statusCode):
            return "Expected request status code between 200 - 299, received \(statusCode)."
        case .unableToParseDataWith(let error):
            return "Unable to parse data, with error: \(error)."
        }
    }
}

final class OpenWeatherAPIService: APIService {
    
    // Replace editor placeholder with your OpenWeatherMap `API key` string
    private let apiKey: String = "fd53c6a1c5478f9d409fd5487979a599"
    
    func fetchCurrentWeather(coordinate: Coordinate,
                             completionHandler: @escaping WeatherForecastCompletionBlock) {
        guard let url = currentWeatherUrlFor(coordinate) else {
            completionHandler(.failure(.invalidURL))
            return
        }
        
#if DEBUG
        print(url)
#endif
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  error == nil else {
                completionHandler(.failure(.emptyDataOrError))
                return
            }
            
            guard 200 ..< 300 ~= response.statusCode else {
                completionHandler(.failure(.unexpectedStatusCode(response.statusCode)))
                return
            }
            
            do {
                let weatherForecast = try JSONDecoder().decode(CurrentWeatherResponse.self, from: data)
                completionHandler(.success(weatherForecast))
            } catch {
                completionHandler(.failure(.unableToParseDataWith(error: error)))
            }
        }.resume()
    }
    
    func fetchCityResults(forQuery query: String) -> AnyPublisher<[City], APIServiceError> {
        guard let url = cityResultsUrlFor(query) else {
            return Fail(error: APIServiceError.invalidURL).eraseToAnyPublisher()
        }
        
#if DEBUG
        print(url)
#endif
        
        let publisher = URLSession.shared.dataTaskPublisher(for: url)
        return publisher
            .tryMap { (data, urlResponse) in
                guard let response = urlResponse as? HTTPURLResponse else {
                    throw APIServiceError.emptyDataOrError
                }
                guard 200 ..< 300 ~= response.statusCode else {
                    throw APIServiceError.unexpectedStatusCode(response.statusCode)
                }
                
                return data
            }
            .decode(type: [City].self, decoder: JSONDecoder())
            .mapError { error -> APIServiceError in
                switch error {
                case let apiError as APIServiceError:
                    return apiError
                case is Swift.DecodingError:
                    return APIServiceError.unableToParseDataWith(error: error)
                default:
                    return APIServiceError.emptyDataOrError
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchGeocodedCities(search: String,
                             completionHandler: @escaping CityResultsCompletionBlock) {
        guard let url = cityResultsUrlFor(search) else {
            completionHandler(.failure(.invalidURL))
            return
        }
        
#if DEBUG
        print(url)
#endif
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  error == nil else {
                completionHandler(.failure(.emptyDataOrError))
                return
            }
            
            guard 200 ..< 300 ~= response.statusCode else {
                completionHandler(.failure(.unexpectedStatusCode(response.statusCode)))
                return
            }
            
            do {
                let cities = try JSONDecoder().decode([City].self, from: data)
                completionHandler(.success(cities))
            } catch {
                completionHandler(.failure(.unableToParseDataWith(error: error)))
            }
        }.resume()
    }
    
    func fecthWeatherIcon(named iconName: String, completionHandler: @escaping IconCompletionBlock) {
        guard let url = iconUrlFor(iconName) else {
            completionHandler(.failure(.invalidURL))
            return
        }
        
#if DEBUG
        print(url)
#endif
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  error == nil else {
                completionHandler(.failure(.emptyDataOrError))
                return
            }
            
            guard 200 ..< 300 ~= response.statusCode else {
                completionHandler(.failure(.unexpectedStatusCode(response.statusCode)))
                return
            }
            
            completionHandler(.success(data))

        }.resume()
    }
}

private extension OpenWeatherAPIService {
    func currentWeatherUrlFor(_ coordinate: Coordinate) -> URL? {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather") else {
            return nil
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            .init(name: "lat", value: "\(coordinate.latitude)"),
            .init(name: "lon", value: "\(coordinate.longitude)"),
            .init(name: "appid", value: apiKey),
            .init(name: "lang", value: "en")
        ]
        
        return components?.url
    }
    
    func iconUrlFor(_ icon: String) -> URL? {
        let str = "https://openweathermap.org/img/wn/"
                    .appending(icon)
                    .appending("@2x.png")        
        return URL(string: str)
    }
    
    func cityResultsUrlFor(_ city: String) -> URL? {
        guard let url = URL(string: "https://api.openweathermap.org/geo/1.0/direct") else {
            return nil
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            .init(name: "q", value: city),
            .init(name: "limit", value: "5"),
            .init(name: "appid", value: apiKey)
        ]
        
        return components?.url
    }
}
