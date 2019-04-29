//
//  flightStatus.swift
//  FlightStatus
//
//  Created by Christopher Knapp on 4/3/19.
//  Copyright © 2019 Christopher Knapp. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Firebase

    struct flightStatus {
        var currentArrivalAirport: String
        var currentDepartureGate: String
        var currentDepartureTime: String
        var currentOnTimeStatus: String
        var currentDepartureAirport: String
        var currentAirlineCode: String
        var currentFlightDigits: String
        var flightID: Int
        var delayTime: Int
        }




