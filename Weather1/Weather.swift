//
//  Weather.swift
//  Weather1
//

import Foundation
import UIKit

struct Weather {
    let location: City
    let current: Weather.Data
    //let forecast: Weather.Data
}

extension Weather {
    struct Data {
        let temperature: Double
        let description: String
        let icon: String
        let group: Int
    }
}

extension Weather {
    enum Icon: String {
        case clearDay = "clear-day"
        case clearNight = "clear-night"
        case rain
        case snow
        case sleet
        case wind
        case fog
        case cloudy
        case partlyCloudyDay = "partly-cloudy-day"
        case partlyCloudyNight = "partly-cloudy-night"
        
        var image: UIImage? {
            switch self {
            case .clearDay:
                return UIImage(systemName: "sun.max")
            case .clearNight:
                return UIImage(systemName: "moon.stars")
            case .rain:
                return UIImage(systemName: "cloud.rain")
            case .snow:
                return UIImage(systemName: "cloud.snow")
            case .sleet:
                return UIImage(systemName: "cloud.sleet")
            case .wind:
                return UIImage(systemName: "wind")
            case .fog:
                return UIImage(systemName: "cloud.fog")
            case .cloudy:
                return UIImage(systemName: "cloud")
            case .partlyCloudyDay:
                return UIImage(systemName: "cloud.sun")
            case .partlyCloudyNight:
                return UIImage(systemName: "cloud.moon")
            }
        }
    }
    
    var background: String {
        switch current.icon.last {
        case .none: return "sun"
        case .some(let char):
            switch char {
            case "n": return backgroundNight
            default: return backgroundDay
            }
        }
    }
    
    var backgroundDay: String {
        // Photos by authors on Unsplash
        switch current.group {
        case 200...299 : return "thunderstorm"
        case 300...399: return "drizzle"
        case 500...599: return "rain"
        case 600...699: return "snow"
        case 700...799: return "mist"
        case 800: return "sun"
        default: return "clouds"
        }
    }
    
    var backgroundNight: String {
        backgroundDay.appending("Night")
    }
}

// MARK: - Temperature formatting
extension Weather {
    static let temperatureFormatter: MeasurementFormatter = {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitOptions = .providedUnit
        measurementFormatter.numberFormatter.maximumFractionDigits = 1
        return measurementFormatter
    }()
    
    var tempCelsius: String {
        let measurement = Measurement(value: current.temperature, unit: UnitTemperature.kelvin)
        let tempCelsius = measurement.converted(to: .celsius)
        return Weather.temperatureFormatter.string(from: tempCelsius)
    }
    
    var tempFahrenheit: String {
        let measurement = Measurement(value: current.temperature, unit: UnitTemperature.kelvin)
        let tempFahrenheit = measurement.converted(to: .fahrenheit)
        return Weather.temperatureFormatter.string(from: tempFahrenheit)
    }
}

// MARK: - Default data
extension Weather {
    static let rigaCity = City(name: "Rīga", localizedNames: nil, country: "LV", state: nil,
                               latitude: 56.948889, longitude: 24.106389)
    static let someWeather = Weather.Data(temperature: 300, description: "Clear sky", icon: "01d", group: 800)
    
    static let riga = Weather(location: rigaCity, current: someWeather)
}

enum TemperatureUnit {
    case celsius
    case fahrenheit
}
