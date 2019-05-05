//
//  ViewController.swift
//  FlightStatus
//
//  Created by Christopher Knapp on 4/3/19.
//  Copyright © 2019 Christopher Knapp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    

    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var addFlight = AddFlightsController()
    var flightStatusArray: [flightStatus] = []
    var flightIDArray: [Int] = []
    var stringOfIDs: [String] = []
    var defaultsData = UserDefaults.standard
    var currentTableViewHeight: Double = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 22, green: 91, blue: 142, alpha: 1)
        stringOfIDs = defaultsData.stringArray(forKey: "stringOfIDs") ?? [String]()
        if stringOfIDs.isEmpty {
            print("string of ids is empty")
            tableView.isHidden = true
        } else {
            flightIDArray = []
        for id in 0...stringOfIDs.count - 1 {
            let intID = Int(stringOfIDs[id])!
            flightIDArray.append(intID)
            print("!!!!!!!Hey the flightIDArray was appended")
        }
            print("!\(flightIDArray)")
        }
        flightStatusArray = []
        if flightIDArray.isEmpty{
            print("hey its empty")
        } else{
            for ID in 0...flightIDArray.count - 1 {
                refreshFlights(flightID: flightIDArray[ID]){
                    print(self.flightStatusArray)
                    self.tableView.reloadData()
                    print("^^^^^hey")
                }
            }
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToDetailedData" {
            let destination = segue.destination as! FlightDetailViewController
            let index = tableView.indexPathForSelectedRow!.row
            destination.flightID = flightStatusArray[index].flightID
            if let selectedPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedPath, animated: false)
            }
            print("segued")
        }
    }
    func createArrayOfIDs(){
        for index in 0...flightStatusArray.count - 1 {
            let id = flightStatusArray[index].flightID
            flightIDArray.append(id)
        }
    }
    
    func refreshFlights(flightID: Int, completed: @escaping ()->()) {
        
        let apiURL = "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/\(flightID)?appId=7feacf78&appKey=efe1aa03255092dac1efc93932181732"
        Alamofire.request(apiURL).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let scheduledDepTime = json["flightStatus"]["operationalTimes"]["scheduledGateDeparture"]["dateLocal"].stringValue
                let scheduledArrTime = json["flightStatus"]["operationalTimes"]["scheduledGateArrival"]["dateLocal"].stringValue
                let depGate = json["flightStatus"]["airportResources"]["departureGate"].stringValue
                let depAirport = json["flightStatus"]["departureAirportFsCode"].stringValue
                let arrAirport = json["flightStatus"]["arrivalAirportFsCode"].stringValue
                let status = json["flightStatus"]["status"].stringValue
                let airline = json["flightStatus"]["carrierFsCode"].stringValue
                let flightNumber = json["flightStatus"]["flightNumber"].stringValue
                let delayTime = json["flightStatus"]["delays"]["departureGateDelayMinutes"].intValue ?? 0
                let allThisData = flightStatus(currentArrivalAirport: arrAirport, currentDepartureGate: depGate, currentDepartureTime: scheduledDepTime, currentOnTimeStatus: status, currentDepartureAirport: depAirport, currentAirlineCode: airline, currentFlightDigits: flightNumber, flightID: flightID, delayTime: delayTime)
                self.flightStatusArray.append(allThisData)
            case .failure(let error):
                print("ERROR: \(error.localizedDescription) failed to get data from url")
                print(apiURL)
            }
            completed()
        }
    }
    
    
    @IBAction func refreshedPressed(_ sender: UIBarButtonItem) {
        if flightStatusArray.isEmpty {
            refreshButton.isEnabled = false
        } else {
        flightIDArray = []
        createArrayOfIDs()
        flightStatusArray = []
        for ID in 0...flightIDArray.count - 1 {
            refreshFlights(flightID: flightIDArray[ID]){
                print(self.flightStatusArray)
                self.tableView.reloadData()
                print("^^^^^hey")
            }
            }
        }
    }
    
    @IBAction func unwindFromAddViewControllerSegue(segue: UIStoryboardSegue){
        let sourceViewController = segue.source as! AddFlightsController
        let newIndexPath = IndexPath(row: flightStatusArray.count, section: 0)
        flightStatusArray.append(sourceViewController.newFlightToAdd!)
        tableView.reloadData()
        print(flightStatusArray)
        saveDefaultsData()

    }
    
    @IBAction func editBarButtonPressed(_ sender: Any) {
        if tableView.isEditing == true {
            tableView.setEditing(false, animated: true)
            editBarButton.title = "Edit"
            addBarButton.isEnabled = true
            tableView.reloadData()
        } else {
            tableView.setEditing(true, animated: true)
            editBarButton.title = "Done"
            addBarButton.isEnabled = false
        }
    }
    func evenOrOdd(number: Int)->Bool{
        if number % 2 == 0  {
            return true
        } else {
            return false
        }
    }
    func tableViewHieght(sections: Int) -> CGFloat{
        currentTableViewHeight = 172 * Double(sections + 1)
        return CGFloat(currentTableViewHeight)
    }
    
    func saveDefaultsData() {
        stringOfIDs = []
        flightIDArray = []
        createArrayOfIDs()
        for id in 0...flightIDArray.count - 1 {
            let stringID = String(flightIDArray[id])
            stringOfIDs.append(stringID)
        }
        defaultsData.set(stringOfIDs,forKey: "stringOfIDs")
        print("*******\(stringOfIDs)")
    }
    
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flightStatusArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        if flightStatusArray.isEmpty {
            print("*** flightStatusArray is empty")
            tableView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        } else {
            print(view.bounds.maxY)
            if Double(view.bounds.maxY) < Double(tableViewHieght(sections: indexPath.row) + 124) {
                tableView.frame = CGRect(x: 0, y: 0, width: view.frame.maxX, height: tableViewHieght(sections: indexPath.row))
                tableView.isScrollEnabled = true
                print("we got here")
            } else {
                print(Double(currentTableViewHeight))
                tableView.frame = CGRect(x: 0, y: 88, width: view.frame.maxX, height: tableViewHieght(sections: indexPath.row))
                tableView.isScrollEnabled = false
                print("%^%^%^Still not there yet")
            }
        }
        
        let flightStatus = flightStatusArray[indexPath.row]
        cell.update(with: flightStatus)
        if evenOrOdd(number: indexPath.row) == false {
            cell.backgroundColor = UIColor.init(red: 31, green: 126, blue: 199, alpha: 1)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 172
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && flightStatusArray.count > 1 {
            flightStatusArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveDefaultsData()
        }
    }
    //removing when nothing left an issue. 
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var flightInfo = addFlight.flightsArray
        let itemToMove = flightInfo[sourceIndexPath.row]
        flightInfo.remove(at: sourceIndexPath.row)
        flightInfo.insert(itemToMove, at: destinationIndexPath.row)
    }
}
