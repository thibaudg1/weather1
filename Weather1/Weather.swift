//
//  Weather.swift
//  Weather1
//

import Foundation
import UIKit

struct Weather {
    let city: String
    let temperature: Double
    let description: String
    let icon: String
    let group: Int
    
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
        // Photos by authors on Unsplash
        switch group {
        case 200...299 : return "thunderstorm"
        case 300...399: return "drizzle"
        case 500...599: return "rain"
        case 600...699: return "snow"
        case 700...799: return "mist"
        case 800: return "sun"
        default: return "clouds"
        }
    }
}

// MARK: - Temperature formatting
extension Weather {
    static let `default` = Weather(city: "Rīga", temperature: 300, description: "Clear sky", icon: "01d", group: 800)
    
    static let temperatureFormatter: MeasurementFormatter = {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitOptions = .providedUnit
        measurementFormatter.numberFormatter.maximumFractionDigits = 1
        return measurementFormatter
    }()
    
    var tempCelsius: String {
        let measurement = Measurement(value: temperature, unit: UnitTemperature.kelvin)
        let tempCelsius = measurement.converted(to: .celsius)
        return Weather.temperatureFormatter.string(from: tempCelsius)
    }
    
    var tempFahrenheit: String {
        let measurement = Measurement(value: temperature, unit: UnitTemperature.kelvin)
        let tempFahrenheit = measurement.converted(to: .fahrenheit)
        return Weather.temperatureFormatter.string(from: tempFahrenheit)
    }
}

enum TemperatureUnit {
    case celsius
    case fahrenheit
}
