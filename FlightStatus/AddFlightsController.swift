//
//  AddFlightsController.swift
//  FlightStatus
//
//  Created by Christopher Knapp on 4/3/19.
//  Copyright © 2019 Christopher Knapp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddFlightsController: UIViewController {
    
    @IBOutlet weak var flightResultLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var flightNumberField: UITextField!
    @IBOutlet weak var originField: UITextField!
    var flightsArray: [FlightStatus] = []
    var newFlightToAdd: FlightStatus!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        var flightMonth = 4
        var flightDay = 26
        var flightYear = 2019
        var airlineCode = ""
        var flightDigits = ""
        var departureAirport = ""
        
        if flightNumberField.text!.count >= 3 && originField.text!.count >= 3 {
            departureAirport = originField.text!
            let length = self.flightNumberField.text?.count
            airlineCode = String(self.flightNumberField.text!.prefix(2))
            print(airlineCode)
            flightDigits = String((self.flightNumberField.text?.suffix(length! - 2))!)
            
            getFlight(airline: airlineCode, flightNumber: flightDigits, departureAirport: departureAirport, month: flightMonth, day: flightDay, year: flightYear) {
                if self.newFlightToAdd.flightID != nil {
                    self.saveButton.isEnabled = true
                    if self.newFlightToAdd.currentDepartureAirport != "" {
                                          self.flightResultLabel.text = "Flight Result: \(airlineCode)\(flightDigits) to \(self.newFlightToAdd.currentArrivalAirport)"
                    } else {
                        self.showAlert(title: "No FLight Found", message: "No flight was found with the given flight number and departure airport.")
                    }
                }
            }
            
        } else {
            showAlert(title: "Invalid Entry", message: "Please enter a Flight Number and Origin Airport")
        }
    }
    
    func getFlight(airline: String, flightNumber: String, departureAirport: String, month: Int, day: Int, year: Int, completed: @escaping ()-> ()){
        let apiURL = "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/\(airline)/\(flightNumber)/dep/\(year)/\(month)/\(day)?appId=0bb794b4&appKey=6ca76d46d5d391b1f5ec6f09b163523b&utc=false&airport=\(departureAirport)&codeType=IATA"
        
        Alamofire.request(apiURL).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let depAir = departureAirport
                let flyDig = flightNumber
                let airCode = airline
                let depGate = json["flightStatuses"][0]["airportResources"]["departureGate"].stringValue
                let arrAirport = json["flightStatuses"][0]["arrivalAirportFsCode"].stringValue
                let depTime = json["flightStatuses"][0]["operationalTimes"]["publishedDeparture"]["dateLocal"].stringValue
                let timeStatus = json["flightStatuses"][0]["status"].stringValue
                let flightID = json["flightStatuses"][0]["flightId"].intValue
                let newFlight = FlightStatus(currentArrivalAirport: arrAirport, currentDepartureGate: depGate, currentDepartureTime: depTime, currentOnTimeStatus: timeStatus, currentDepartureAirport: depAir, currentAirlineCode: airCode, currentFlightDigits: flyDig, flightID: flightID)
                self.newFlightToAdd = newFlight
                print(self.newFlightToAdd)
            case .failure(let error):
                print("ERROR: \(error.localizedDescription) failed to get data from url")
                print(apiURL)
            }
            completed()
        }
        
    }
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

