//
//  FlightDetailViewController.swift
//  FlightStatus
//
//  Created by Christopher Knapp on 4/21/19.
//  Copyright © 2019 Christopher Knapp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import UberRides
import CoreLocation

class FlightDetailViewController: UIViewController {
    
    struct detailedFlightData {
        var scheduledDepartureTime: String
        var estimatedDepartureTime: String
        var scheduledArrivalTime: String
        var estimatedArrivalTime: String
        var departureGate: String
        var arrivalGate: String
        var baggageClaim: String
        var departureAirport: String
        var arrivalAirport: String
        var equipmentData: String
        var flightDuration: Int
        var status: String
        var airline: String
        var flightNumber: String
        var uberDestinationLatitude: Double
        var uberDestinationLongitude: Double
    }
    
    @IBOutlet weak var departureAirport: UILabel!
    @IBOutlet weak var arrivalAirport: UILabel!
    @IBOutlet weak var departureGate: UILabel!
    @IBOutlet weak var scheduledDepartureTime: UILabel!
    @IBOutlet weak var estimatedDepartureTime: UILabel!
    @IBOutlet weak var scheduledArrivalTime: UILabel!
    @IBOutlet weak var estimatedArrivalTime: UILabel!
    @IBOutlet weak var equipment: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var estimatedDepartureHidden: UILabel!
    @IBOutlet weak var estimatedArrivalHidden: UILabel!
    @IBOutlet weak var arrivalGateHidden: UILabel!
    @IBOutlet weak var arrivalGate: UILabel!
    @IBOutlet weak var bagLabel: UILabel!
    @IBOutlet weak var bagLabelHidden: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var flightNumberLabel: UILabel!
    
    var detailedFlightInformation: detailedFlightData!
    var flightID: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFlightDetail(flightID: flightID) {
            
            self.updateUserInterface()
            print(self.detailedFlightInformation)
            let button = RideRequestButton()
            let dropoffLocation = CLLocation(latitude: self.detailedFlightInformation.uberDestinationLatitude, longitude: self.detailedFlightInformation.uberDestinationLongitude)
            let builder = RideParametersBuilder()
            builder.dropoffLocation = dropoffLocation
            builder.dropoffNickname = "\(self.detailedFlightInformation.departureAirport)"
            button.rideParameters = builder.build()
            button.center = self.view.center
            //self.view.addSubview(button)
        }
    }
    
    func getFlightDetail(flightID: Int, completed: @escaping ()-> ()){
        let apiURL = "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/\(flightID)?appId=0bb794b4&appKey=6ca76d46d5d391b1f5ec6f09b163523b"
        
        Alamofire.request(apiURL).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let scheduledDepTime = json["flightStatus"]["operationalTimes"]["scheduledGateDeparture"]["dateLocal"].stringValue
                let estimatedDepTime = json["flightStatus"]["operationalTimes"]["estimatedGateDeparture"]["dateLocal"].stringValue
                let scheduledArrTime = json["flightStatus"]["operationalTimes"]["scheduledGateArrival"]["dateLocal"].stringValue
                let estArrTime = json["flightStatus"]["operationalTimes"]["estimatedGateArrival"]["dateLocal"].stringValue
                let depGate = json["flightStatus"]["airportResources"]["departureGate"].stringValue
                let arrGate = json["flightStatus"]["airportResources"]["arrivalGate"].stringValue
                let bagClaim = json["flightStatus"]["airportResources"]["baggage"].stringValue
                let depAirport = json["flightStatus"]["departureAirportFsCode"].stringValue
                let arrAirport = json["flightStatus"]["arrivalAirportFsCode"].stringValue
                let whatPlane = json["appendix"]["equipments"][0]["name"].stringValue
                let howLong = json["flightStatus"]["flightDurations"]["scheduledBlockMinutes"].intValue
                let status = json["flightStatus"]["status"].stringValue
                let airline = json["flightStatus"]["carrierFsCode"].stringValue
                let flightNumber = json["flightStatus"]["flightNumber"].stringValue
                let airportLatitude = json["appendix"]["airports"][1]["latitude"].doubleValue
                let airportLongitude = json["appendix"]["airports"][1]["longitude"].doubleValue
                let allThisData = detailedFlightData(scheduledDepartureTime: scheduledDepTime, estimatedDepartureTime: estimatedDepTime, scheduledArrivalTime: scheduledArrTime, estimatedArrivalTime: estArrTime, departureGate: depGate, arrivalGate: arrGate, baggageClaim: bagClaim, departureAirport: depAirport, arrivalAirport: arrAirport, equipmentData: whatPlane, flightDuration: howLong, status: status, airline: airline, flightNumber: flightNumber, uberDestinationLatitude: airportLatitude, uberDestinationLongitude: airportLongitude)
                self.detailedFlightInformation = allThisData
            case .failure(let error):
                print("ERROR: \(error.localizedDescription) failed to get data from url")
                print(apiURL)
            }
            completed()
        }
        
    }
    func updateUserInterface(){
        departureGate.text = detailedFlightInformation.departureGate
        departureAirport.text = detailedFlightInformation.departureAirport
        arrivalAirport.text = detailedFlightInformation.arrivalAirport
        scheduledDepartureTime.text = formatTime(time: detailedFlightInformation.scheduledDepartureTime)
        scheduledArrivalTime.text = formatTime(time: detailedFlightInformation.scheduledArrivalTime)
        equipment.text = detailedFlightInformation.equipmentData
        if detailedFlightInformation.baggageClaim != "" {
            bagLabel.text = detailedFlightInformation.baggageClaim
        } else {
            bagLabelHidden.isHidden = true
            bagLabel.text = ""
        }
        if detailedFlightInformation.arrivalGate != "" {
            arrivalGate.text = detailedFlightInformation.arrivalGate
        } else {
            arrivalGate.text = "TBD"
        }
        if detailedFlightInformation.estimatedArrivalTime != "" {
            estimatedArrivalTime.text = formatTime(time: detailedFlightInformation.estimatedArrivalTime)
        } else {
            estimatedArrivalHidden.isHidden = true
            estimatedArrivalTime.text = ""
        }
        if detailedFlightInformation.estimatedDepartureTime != "" {
            estimatedDepartureTime.text = formatTime(time: detailedFlightInformation.estimatedDepartureTime)
        } else {
            estimatedDepartureHidden.isHidden = true
            estimatedDepartureTime.text = ""
        }
        switch detailedFlightInformation.status {
        case "A":
            status.text = "In Flight"
        case "C":
            status.text = "Cancelled"
            status.textColor = UIColor.red
        case "D":
            status.text = "Diverted"
            status.textColor = UIColor.red
        case "DN":
            status.text = "No Data"
            status.textColor = UIColor.black
        case "L":
            status.text = "Landed"
        case "NO":
            status.text = "Not Operational"
            status.textColor = UIColor.black
        case "R":
            status.text = "Redirected"
            status.textColor = UIColor.red
        case "S":
            status.text = "Scheduled"
        case "U":
            status.text = "Unknown"
            status.textColor = UIColor.black
        default:
            status.text = ""
        }
        duration.text = formatDuration(time: detailedFlightInformation.flightDuration)
        flightNumberLabel.text = detailedFlightInformation.flightNumber
    }
    
    func formatDuration(time: Int) -> String {
        let hours = time / 60
        let minutes = time % 60
        if minutes % 60 < 10{
            return "\(hours):0\(minutes)"
        }else {
            return "\(hours):\(minutes)"
        }
    }
    func formatTime(time: String) -> String {
        //2019-04-22T15:56:00.000
        let removedDate = time.dropFirst(11)
        let removedSecondsAndDate = removedDate.dropLast(7)
        var hours = removedSecondsAndDate.dropLast(3)
        var intHours = Int(hours)
        let minutes = removedSecondsAndDate.dropFirst(3)
        if intHours! > 12 {
            intHours = intHours! - 12
            return "\(intHours!):\(minutes) PM"
        } else {
            return "\(intHours!):\(minutes)"
        }
    }

}


