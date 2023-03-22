//
//  APIService.swift
//  Weather1
//

import Foundation

typealias Coordinate = (latitude: Double, longitude: Double)
typealias WeatherForecastCompletionBlock = (Result<CurrentWeatherResponse, APIServiceError>) -> Void

protocol APIService {
    func fetchCurrentWeather(coordinate: Coordinate,
                             completionHandler: @escaping WeatherForecastCompletionBlock)
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
        
        guard let completeUrl = components?.url else {
            return nil
        }
        
        return completeUrl
    }
}