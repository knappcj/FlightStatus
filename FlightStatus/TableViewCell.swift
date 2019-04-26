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
    
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var flightNumberLabel: UILabel!
    @IBOutlet weak var departureAirportLabel: UILabel!
    @IBOutlet weak var arrivalAirportLabel: UILabel!
    @IBOutlet weak var gateLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func update(with flightInformation: FlightStatus) {        
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
        case "U":
            statusLabel.text = "Unknown"
            statusLabel.textColor = UIColor.black
        default:
            statusLabel.text = ""
        }
    }
}
