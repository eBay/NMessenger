//
//  EntryViewController.swift
//  MessageGroups
//
//  Created by Max Alexander on 11/21/16.
//  Copyright © 2016 Ebay Inc. All rights reserved.
//

import UIKit
import LoremIpsum

class EntryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    lazy var items : [String] = [
        "Empty",
        "50 Preloaded Messages"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        title = "Welcome to NMessenger"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell()
        let item = items[indexPath.row]
        cell.textLabel?.text = item
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let exampleViewController = ExampleMessengerViewController()
        if indexPath.row == 1 {
            exampleViewController.bootstrapWithRandomMessages = 3
        }
        navigationController?.pushViewController(exampleViewController, animated: true)
    }
}
