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

class FlightStatus {
    
            var arrivalAirport = ""
            var departureTime = 0
            var departureGate = ""
            var onTimeStatus = ""
        
        var flightStatusArray: [FlightStatus] = []
    
    func getFlight(completed: @escaping ()-> () ){
        Alamofire.request(apiURL).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.arrivalAirport = json[].string ?? ""
                self.departureTime = json[].int ?? 0
                self.departureGate = json[].string ?? ""
                self.onTimeStatus = json[].string ?? ""
                
            case .failure(let error):
                print("ERROR: \(error.localizedDescription) failed to get data from url")
            }
            completed()
        }

    }
    
}



