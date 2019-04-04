//
//  AddFlightsController.swift
//  FlightStatus
//
//  Created by Christopher Knapp on 4/3/19.
//  Copyright © 2019 Christopher Knapp. All rights reserved.
//

import UIKit

class AddFlightsController: UIViewController {
    
    @IBOutlet weak var flightNumberField: UITextField!
    @IBOutlet weak var originField: UITextField!
    
    var flights = FlightStatus()
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        if flightNumberField.text!.count >= 3 && originField.text!.count >= 3 {
            flights.getFlight {
                let length = self.flightNumberField.text?.count
                airlineCode = String(self.flightNumberField.text!.prefix(2))
                flightDigits = String((self.flightNumberField.text?.suffix(length! - 2))!)
            }
        } else {
          showAlert(title: "Invalid Entry", message: "Please enter a Flight Number and Origin Airport")
        }
    }
    
}
