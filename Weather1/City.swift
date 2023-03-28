//
//  City.swift
//  Weather1
//

import Foundation

struct City: Decodable {
    let name: String
    let localizedNames: Dictionary<String, String>?
    let country: String
    let state: String?
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case name, state, country
        case localizedNames = "local_names"
        case latitude = "lat"
        case longitude = "lon"
    }
}

extension City {
    func localizedName(for language: String) -> String {
        guard let localized = localizedNames?[language] else {
            return name
        }        
        return localized
    }
}

extension City {
    static let cities: [City] = [
        City(name: "London", localizedNames: [:], country: "GB", state: nil, latitude: 51.5085, longitude: -0.1257),
        City(name: "London", localizedNames: [:], country: "CA", state: nil, latitude: 42.9834, longitude: -81.233),
        City(name: "London", localizedNames: [:], country: "US", state: "OH", latitude: 39.8865, longitude: -83.4483),
        City(name: "London", localizedNames: [:], country: "US", state: "KY", latitude: 37.129, longitude: -84.0833),
        City(name: "London", localizedNames: [:], country: "US", state: "CA", latitude: 36.4761, longitude: -119.4432)
    ]
}
