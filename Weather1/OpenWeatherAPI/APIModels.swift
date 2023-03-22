//
//  Models.swift
//  Weather1
//

import Foundation

// MARK: - CurrentWeather Response
struct CurrentWeatherResponse: Codable {
    let coordinates: Coordinates
    let weather: [WeatherOWA]

    let main: Main
//    let visibility: Int
//    let wind: Wind
//    let rain: Rain
//    let clouds: Clouds
//    let dataTime: Int
//    let system: System
//    let timezone: Int
    let cityID: Int
    let cityName: String


    enum CodingKeys: String, CodingKey {
        case coordinates = "coord"
        case weather = "weather"

        case main = "main"
//        case visibility = "visibility"
//        case wind = "wind"
//        case rain = "rain"
//        case clouds = "clouds"
//        case dataTime = "dt"
//        case system = "sys"
//        case timezone = "timezone"
        case cityID = "id"
        case cityName = "name"

    }
}

// MARK: - Clouds
struct Clouds: Codable {
    let cloudiness: Int

    enum CodingKeys: String, CodingKey {
        case cloudiness = "all"
    }
}

// MARK: - Coordinates
struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double

    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
    }
}

// MARK: - Main
struct Main: Codable {
    let temperature: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let pressureSeaLevel: Int?
    let pressureGroundLevel: Int?

    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure = "pressure"
        case humidity = "humidity"
        case pressureSeaLevel = "sea_level"
        case pressureGroundLevel = "grnd_level"
    }
}

// MARK: - Rain
struct Rain: Codable {
    let lastHour: Double?
    let last3hours: Double?

    enum CodingKeys: String, CodingKey {
        case lastHour = "1h"
        case last3hours = "3h"
    }
}

// MARK: - System
struct System: Codable {
    let type: Int
    let id: Int
    let country: String
    let sunrise: Int
    let sunset: Int

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case id = "id"
        case country = "country"
        case sunrise = "sunrise"
        case sunset = "sunset"
    }
}

// MARK: - WeatherOWA
struct WeatherOWA: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case main = "main"
        case description = "description"
        case icon = "icon"
    }
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
    let direction: Int
    let gust: Double

    enum CodingKeys: String, CodingKey {
        case speed = "speed"
        case direction = "deg"
        case gust = "gust"
    }
}
