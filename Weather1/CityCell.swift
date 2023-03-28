//
//  CityCell.swift
//  Weather1
//

import UIKit

class CityCell: UITableViewCell {
    @IBOutlet var stateLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!
    
    var language = "en"
    
    var city: City? {
        didSet {
            guard let city = city else { return }
            
            cityLabel.text = city.localizedName(for: language)
            countryLabel.text = city.country
            stateLabel.text = city.state
        }
    }
}
