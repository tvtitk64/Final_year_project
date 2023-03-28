//
//  ViewController.swift
//  ipsGG
//
//  Created by Dương Sơn on 3/19/19.
//  Copyright © 2019 Dương Sơn. All rights reserved.
//

import UIKit


class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var start : String = String()
    var end : String = String()
    let data = ["Room 101", "Room 103", "Room 107", "Men WC", "Women WC",
                "Computer Center", "Entrance", "Room 102", "Room 106"/*,
                "Room 201", "Room 202", "Room 203", "Room 204",
                "Room 205", "Room 206", "Room 206a", "Room 207",
                "Room 208", "Room 209", "Room 210", "Room 202G2b"*/]
    var filteredData: [String]!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
//    struct AlertHelper {
//        static func showAlert(title: String, message: String, buttonText: String) -> Alert {
//            return Alert(title: Text(title), message: Text(message), dismissButton: .default(Text(buttonText)))
//        }
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == fromTable{
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as UITableViewCell
            cell1.textLabel?.text = filteredData[indexPath.row]
            return cell1
        } else {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as UITableViewCell
            cell2.textLabel?.text = filteredData[indexPath.row]
            return cell2
        }	
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == fromTable{
            start = filteredData[indexPath.row]
        }
        else {
            end = filteredData[indexPath.row]
        }
    }

    @IBOutlet weak var fromTable: UITableView!
    @IBOutlet weak var fromSearchBar: UISearchBar!
    @IBOutlet weak var toTable: UITableView!
    @IBOutlet weak var toSearchBar: UISearchBar!
    @IBOutlet weak var routeButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        fromTable.delegate = self
        fromTable.dataSource = self
        fromSearchBar.delegate = self
        toTable.delegate = self
        toTable.dataSource = self
        toSearchBar.delegate = self
        filteredData = data
        self.fromTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell1")
        self.toTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell2")
        fromSearchBar.placeholder = "Bắt đầu"
        fromSearchBar.searchBarStyle = UISearchBar.Style.minimal
        fromSearchBar.tintColor = UIColor.white
        toSearchBar.placeholder = "Đích đến"
        toSearchBar.searchBarStyle = UISearchBar.Style.minimal
        toSearchBar.tintColor = UIColor.white
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? data : data.filter { (item: String) -> Bool in
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        fromTable.reloadData()
        toTable.reloadData()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.fromSearchBar.showsCancelButton = true
        self.toSearchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fromSearchBar.showsCancelButton = false
        fromSearchBar.text = ""
        fromSearchBar.resignFirstResponder()
        toSearchBar.showsCancelButton = false
        toSearchBar.text = ""
        toSearchBar.resignFirstResponder()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "go"{
            let mapViewController = segue.destination as! MapViewController
            mapViewController.Start.name = start
            mapViewController.Destination.name = end
        }
    }
}

