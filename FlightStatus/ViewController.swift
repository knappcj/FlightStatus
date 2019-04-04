//
//  ViewController.swift
//  FlightStatus
//
//  Created by Christopher Knapp on 4/3/19.
//  Copyright © 2019 Christopher Knapp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var flightStatuss = FlightStatus()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      tableView.delegate = self
        tableView.dataSource = self
    }


}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flightStatuss.flightStatusArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    
}

