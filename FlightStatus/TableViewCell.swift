//
//  TableViewCell.swift
//  FlightStatus
//
//  Created by Christopher Knapp on 4/4/19.
//  Copyright © 2019 Christopher Knapp. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    let flights = AddFlightsController()
    
    
    @IBOutlet weak var departureTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var flightNumberLabel: UILabel!
    @IBOutlet weak var departureAirportLabel: UILabel!
    @IBOutlet weak var arrivalAirportLabel: UILabel!
    @IBOutlet weak var gateLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func update(with flightInformation: flightStatus) {
        departureTimeLabel.text = formatTime(time: flightInformation.currentDepartureTime)
        flightNumberLabel.text = flightInformation.currentAirlineCode + flightInformation.currentFlightDigits
        departureAirportLabel.text = flightInformation.currentDepartureAirport
        arrivalAirportLabel.text = flightInformation.currentArrivalAirport
        gateLabel.text = flightInformation.currentDepartureGate
        
        switch flightInformation.currentOnTimeStatus {
        case "A":
            statusLabel.text = "In Flight"
        case "C":
            statusLabel.text = "Cancelled"
            statusLabel.textColor = UIColor.red
        case "D":
            statusLabel.text = "Diverted"
            statusLabel.textColor = UIColor.red
        case "DN":
            statusLabel.text = "No Data"
            statusLabel.textColor = UIColor.black
        case "L":
            statusLabel.text = "Landed"
        case "NO":
            statusLabel.text = "Not Operational"
            statusLabel.textColor = UIColor.black
        case "R":
            statusLabel.text = "Redirected"
            statusLabel.textColor = UIColor.red
        case "S":
            statusLabel.text = "Scheduled"
            if flightInformation.delayTime > 15 {
                statusLabel.textColor = UIColor.yellow
                statusLabel.text = "Delayed"
            }
        case "U":
            statusLabel.text = "Unknown"
            statusLabel.textColor = UIColor.black
        default:
            statusLabel.text = ""
        }
    }
    func formatTime(time: String) -> String {
        //2019-04-22T15:56:00.000
        let removedDate = time.dropFirst(11)
        let removedSecondsAndDate = removedDate.dropLast(7)
        var hours = removedSecondsAndDate.dropLast(3)
        var intHours = Int(hours)
        let minutes = removedSecondsAndDate.dropFirst(3)
        if intHours! > 11 {
            intHours = intHours! - 12
            if intHours == 0 {
                return"\(12):\(minutes) PM"
            }
            return "\(intHours!):\(minutes) PM"
        } else {
            return "\(intHours!):\(minutes) AM"
        }
    }
}
