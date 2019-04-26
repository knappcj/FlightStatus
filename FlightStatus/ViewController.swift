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
import Firebase
import FirebaseUI
import GoogleSignIn

class ViewController: UIViewController {
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var addFlight = AddFlightsController()
    var flightStatusArray: [FlightStatus] = []
    var flightIDArray: [Int] = []
    var authUI: FUIAuth!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    
    func signIn() {
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
        ]
        if authUI.auth?.currentUser == nil {
            self.authUI.providers = providers
            present(authUI.authViewController(), animated: true, completion: nil)
        } else {
            tableView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 22, green: 91, blue: 142, alpha: 1)
        if flightStatusArray.isEmpty {
            print("is empty")
        } else {
            createArrayOfIDs()
            for ID in flightIDArray {
                refreshFlights(flightID: ID){
                    print(self.flightStatusArray)
                    
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToDetailedData" {
            let destination = segue.destination as! FlightDetailViewController
            let index = tableView.indexPathForSelectedRow!.row
            destination.flightID = flightStatusArray[index].flightID
            print("say whaaat")
        }
    }
    func createArrayOfIDs(){
        for index in 0...flightStatusArray.count - 1 {
            let id = flightStatusArray[index].flightID
            flightIDArray.append(id)
        }
        flightStatusArray = []
    }
    
    func refreshFlights(flightID: Int, completed: @escaping ()->()) {
        
        let apiURL = "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/\(flightID)?appId=0bb794b4&appKey=6ca76d46d5d391b1f5ec6f09b163523b"
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
                let allThisData = FlightStatus(currentArrivalAirport: arrAirport, currentDepartureGate: depAirport, currentDepartureTime: scheduledDepTime, currentOnTimeStatus: status, currentDepartureAirport: depAirport, currentAirlineCode: airline, currentFlightDigits: flightNumber, flightID: flightID)
                self.flightStatusArray.append(allThisData)
            case .failure(let error):
                print("ERROR: \(error.localizedDescription) failed to get data from url")
                print(apiURL)
            }
            completed()
        }
    }
    

    
    @IBAction func unwindFromAddViewControllerSegue(segue: UIStoryboardSegue){
        let sourceViewController = segue.source as! AddFlightsController
        let newIndexPath = IndexPath(row: flightStatusArray.count, section: 0)
        flightStatusArray.append(sourceViewController.newFlightToAdd!)
        tableView.reloadData()
        print(flightStatusArray)
    }
    @IBAction func signOutPressed(_ sender: Any) {
        do{
            try authUI!.signOut()
            tableView.isHidden = true
            signIn()
        } catch {
            print("error: it done got caught")
        }
        
    }
    
    @IBAction func editBarButtonPressed(_ sender: Any) {
        if tableView.isEditing == true {
            tableView.setEditing(false, animated: true)
            editBarButton.title = "Edit"
            addBarButton.isEnabled = true
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
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flightStatusArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        if evenOrOdd(number: indexPath.row) == false {
            cell.backgroundColor = UIColor.init(red: 31, green: 126, blue: 199, alpha: 1)
        }
        let flightStatus = flightStatusArray[indexPath.row]
        cell.update(with: flightStatus)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 131
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var flightInfo = addFlight.flightsArray
            flightInfo.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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

extension ViewController: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        loginViewController.view.backgroundColor = UIColor.white
        
        let marginInsets: CGFloat = 16
        let imageHeight: CGFloat = 225
        let imageY = self.view.center.y - imageHeight
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInsets, y: imageY, width: self.view.frame.width - (marginInsets * 2), height: imageHeight)
        //let logoImageView = UIImageView(frame: logoFrame)
        //logoImageView.image = UIImage(named: "logo")
        //logoImageView.contentMode = .scaleAspectFit
        //loginViewController.view.addSubview(logoImageView)
        
        return loginViewController
    }
}
