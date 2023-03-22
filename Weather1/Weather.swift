//
//  Weather.swift
//  Weather1
//

import Foundation
import UIKit

struct Weather {
    let city: String
    let temperature: String
    let description: String
    let icon: Icon    
    
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
}
