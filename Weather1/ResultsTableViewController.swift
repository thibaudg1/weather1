//
//  ResultsTableViewController.swift
//  Weather1
//

import UIKit

protocol ResultsTableViewDelegate: AnyObject {
    func didSelect(city: City)
}

class ResultsTableViewController: UITableViewController {
    weak var delegate: ResultsTableViewDelegate?
    
    var language = "en"
    
    var results: [City]? {
        didSet {
            tableView.reloadData()
        }
    }
    var suggestions: [City] {
        City.cities
    }
    var isShowingResults: Bool {
        return results != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureBlurView()
        super.viewWillAppear(animated)
    }
    
    func configureBlurView() {
        if UIAccessibility.isReduceTransparencyEnabled {
            tableView.backgroundColor = .systemBackground
            tableView.backgroundView = nil
        } else {
            tableView.backgroundColor = UIColor.clear
            let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            tableView.backgroundView = blurEffectView
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isShowingResults ? (results?.count ?? 0) : suggestions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isShowingResults,
           let cell = tableView.dequeueReusableCell(withIdentifier: "results",
                                                    for: indexPath) as? CityCell {
            cell.city = results?[indexPath.row]
            cell.language = language
            
            return cell
            
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "results",
                                                           for: indexPath) as? CityCell {
            cell.city = suggestions[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = isShowingResults ? results![indexPath.row] : suggestions[indexPath.row]
        delegate?.didSelect(city: city)
    }
}
