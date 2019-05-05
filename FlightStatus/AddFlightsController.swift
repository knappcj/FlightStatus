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
    var flightsArray: [flightStatus] = []
    var newFlightToAdd: flightStatus!
    @IBOutlet weak var txtDatePicker: UITextField!
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        showDatePicker()
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        if flightNumberField.text!.count >= 3 && originField.text!.count >= 3 && txtDatePicker.text != nil{
            let flightMonth = formatMonth(date: txtDatePicker.text!)
            let flightDay = formatDay(date: txtDatePicker.text!)
            let flightYear = formatYear(date: txtDatePicker.text!)
            var airlineCode = ""
            var flightDigits = ""
            var departureAirport = ""
            departureAirport = originField.text!
            let length = self.flightNumberField.text?.count
            airlineCode = String(self.flightNumberField.text!.prefix(2))
            print(airlineCode)
            flightDigits = String((self.flightNumberField.text?.suffix(length! - 2))!)
          flightDigits = flightDigits.trimmingCharacters(in: .whitespaces)
            departureAirport = departureAirport.trimmingCharacters(in: .whitespaces)
            
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
        let apiURL = "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/\(airline)/\(flightNumber)/dep/\(year)/\(month)/\(day)?appId=7feacf78&appKey=efe1aa03255092dac1efc93932181732&utc=false&airport=\(departureAirport)&codeType=IATA"
        
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
                let delayTime = json["flightStatues"][0]["delays"]["departureGateDelayMinutes"].intValue ?? 0
                let newFlight = flightStatus(currentArrivalAirport: arrAirport, currentDepartureGate: depGate, currentDepartureTime: depTime, currentOnTimeStatus: timeStatus, currentDepartureAirport: depAir, currentAirlineCode: airCode, currentFlightDigits: flyDig, flightID: flightID, delayTime: delayTime)
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
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        txtDatePicker.inputAccessoryView = toolbar
        txtDatePicker.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        txtDatePicker.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    func formatMonth(date: String) -> Int {
        let month = date.dropLast(8)
        let intMonth = Int(month)!
        return intMonth
    }
    
    func formatDay(date: String) -> Int {
        let droppedMonth = date.dropFirst(3)
        let droppedMonthAndYear = droppedMonth.dropLast(5)
        let intDay = Int(droppedMonthAndYear)!
        return intDay
    }
    
    func formatYear(date: String) -> Int {
        let year = date.dropFirst(6)
        let intYear = Int(year)!
        return intYear
    }
    }


