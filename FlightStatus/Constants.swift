//
//  Constants.swift
//  FlightStatus
//
//  Created by Christopher Knapp on 4/3/19.
//  Copyright © 2019 Christopher Knapp. All rights reserved.
//

import Foundation

var flightMonth = ""
var flightDay = ""
var flightYear = ""
var airlineCode = ""
var flightDigits = ""
var departureAirport = ""
var apiKey = "6ca76d46d5d391b1f5ec6f09b163523b"
var appID = "0bb794b4"
var apiURL  = "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/\(airlineCode)/\(flightDigits)/dep/\(flightYear)/\(flightMonth)/\(flightDay)?appId=0bb794b4&appKey=6ca76d46d5d391b1f5ec6f09b163523b&utc=false&airport=\(departureAirport)&codeType=IATA"
