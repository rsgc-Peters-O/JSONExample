//
//  ViewController.swift
//  CoolingCentreFinder
//  Created by Oscar Peters


import UIKit
import CoreLocation     // Required to obtain user's location
import Foundation
import MapKit

// Allow for degrees <--> radians conversions
extension Double {
    var degreesToRadians: Double { return self * M_PI / 180 }
    var radiansToDegrees: Double { return self * 180 / M_PI }
}

// An extension is a Swift language construct that, as the name implies,
// allows you to extend, or add functionality to, an existing type or class.
// In this case, we are adding functionality to the UIView class.
//
// Note that UIView class is a super-class for all the UI elements we are using
// here (UILabel, UITextField, UIButton).
// So if we write an extension for UIView, all the sub-classes of UIView have this
// new functionality as well.
extension UIView {
    
    // A convenience function that saves us directly invoking the rather verbose
    // NSLayoutConstraint initializer on each and every object in the interface.
    func centerHorizontallyInSuperview(){
        let c: NSLayoutConstraint = NSLayoutConstraint(item: self,
                                                       attribute: NSLayoutAttribute.centerX,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: self.superview,
                                                       attribute: NSLayoutAttribute.centerX,
                                                       multiplier:1,
                                                       constant: 0)
        
        // Add this constraint to the superview
        self.superview?.addConstraint(c)
        
    }
    
}

class ViewController : UIViewController {
    
    // Whether to show debug output from JSON retrieval
    var debugOutput : Bool = false
    
    // Views that need to be accessible to all methods
    let jsonResult = UILabel()
    
    // If data is successfully retrieved from the server, we can parse it here
    func parseMyJSON(_ theData : Data) {
        
        // Print the provided data
        print("")
        print("====== the data provided to parseMyJSON is as follows ======")
        print(theData)
        
        // Convert the data into a String
        guard var rawDataAsString = String(data: theData, encoding: .utf8) else {
            print("could not convert data to string")
            return
        }
        rawDataAsString.remove(at: rawDataAsString.startIndex)
        rawDataAsString.remove(at: rawDataAsString.startIndex)
        rawDataAsString.remove(at: rawDataAsString.startIndex)
        rawDataAsString.remove(at: rawDataAsString.startIndex)
        print(rawDataAsString)
        
        guard let fixedData = rawDataAsString.data(using: .utf8) else {
            print("Could not convert back into an object of type Data")
            return
        }
        
        // De-serializing JSON can throw errors, so should be inside a do-catch structure
        do {
            
            //---------------------------------------------------------------------------------------------------------------------------------------------
            // JSON de-serialization:
            //---------------------------------------------------------------------------------------------------------------------------------------------
            // allTickerData will contain the entire contents of the market info for one product
            //
            // for example:
            //
            //            [{
            //                c = "-0.45";                          // change ($) at closing        // infoClosingChange
            //                cp = "-0.31";                         // change (%) at closing        // infoClosingPercent
            //                div = "0.57";                         //
            //                e = NASDAQ;                           // exchange                     // infoExchange
            //                ec = "-0.53";                         //
            //                ecp = "-0.36";                        //
            //                el = "146.53";                        // current price                // infoCurrentPrice
            //                elt = "May 3, 7:40PM EDT";            // date and time                // infoCurrentDate
            //                l = "147.06";                         // closing price                // infoClosingPrice
            //                lt = "May 3, 4:00PM EDT";             // data and time                // infoClosingDate
            //                ltt = "4:00PM EDT";                   //
            //                t = AAPL;                             // ticker name                  // infoTicker
            //                yld = "1.55";                         // yield                        // infoYield
            //                }]
            //---------------------------------------------------------------------------------------------------------------------------------------------
            
            let allTickerData = try JSONSerialization.jsonObject(with: fixedData, options: JSONSerialization.ReadingOptions.allowFragments) as! [AnyObject]

            //---------------------------------------------------------------------------------------------------------------------------------------------
            // Print the entire contents of the JSON
            //---------------------------------------------------------------------------------------------------------------------------------------------
            
            print(allTickerData)
            
            //---------------------------------------------------------------------------------------------------------------------------------------------
            // Obtain the "first" database entry of the JSON (only going to have 1 content; searching a single stock now; could search multiple later)
            //---------------------------------------------------------------------------------------------------------------------------------------------
            
            guard let tickerData = allTickerData.first as? [String : AnyObject] else {
                print("Could not convert to dictornary")
                return
            }

            //---------------------------------------------------------------------------------------------------------------------------------------------
            // From "tickerData" entry, obtain the desired information on the stock
            //---------------------------------------------------------------------------------------------------------------------------------------------

            guard let infoTicker = tickerData["t"] as? String else {
                print("Could not obtain the name of the stock")
                return
            }
            guard let infoExchange = tickerData["e"] as? String else {
                print("Could not obtain the exchange of the stock")
                return
            }
            guard let infoCurrentDate = tickerData["elt"] as? String else {
                print("Could not obtain the name of the stock")
                return
            }
            guard let infoCurrentPrice = tickerData["el"] as? String else {
                print("Could not obtain the name of the stock")
                return
            }
            guard let infoClosingDate = tickerData["lt"] as? String else {
                print("Could not obtain the name of the stock")
                return
            }
            guard let infoClosingPrice = tickerData["l"] as? String else {
                print("Could not obtain the name of the stock")
                return
            }
            guard let infoClosingChange = tickerData["c"] as? String else {
                print("Could not obtain the name of the stock")
                return
            }
            guard let infoClosingPercent = tickerData["cp"] as? String else {
                print("Could not obtain the name of the stock")
                return
            }
            guard let infoYield = tickerData["yld"] as? String else {
                print("Could not obtain the name of the stock")
                return
            }

            //---------------------------------------------------------------------------------------------------------------------------------------------
            // Store the information as a single string (using newlines) so it's easier dump later to text field as output
            //---------------------------------------------------------------------------------------------------------------------------------------------
            
            var infoSummary = ""
            
            infoSummary += "-------------------------------"
            infoSummary += "\n"
            infoSummary += "Stock Name:  "
            infoSummary += infoTicker
            infoSummary += "\n"
            infoSummary += "-------------------------------"
            infoSummary += "\n"
            infoSummary += "Exchange:    "
            infoSummary += infoExchange
            infoSummary += "\n"
            infoSummary += "-------------------------------"
            infoSummary += "\n"
            infoSummary += "Currently:   "
            infoSummary += infoCurrentDate
            infoSummary += "\n"
            infoSummary += "Price is:    "
            infoSummary += infoCurrentPrice
            infoSummary += "\n"
            infoSummary += "-------------------------------"
            infoSummary += "\n"
            infoSummary += "At Closing:  "
            infoSummary += infoClosingDate
            infoSummary += "\n"
            infoSummary += "Price is:    "
            infoSummary += infoClosingPrice
            infoSummary += "\n"
            infoSummary += "Change:      "
            infoSummary += infoClosingChange
            infoSummary += "  "
            infoSummary += infoClosingPercent
            infoSummary += "%"
            infoSummary += "\n"
            infoSummary += "Yield:       "
            infoSummary += infoYield
            infoSummary += "%"
            infoSummary += "\n"
            infoSummary += "-------------------------------"
            infoSummary += "\n"

            //---------------------------------------------------------------------------------------------------------------------------------------------
            // Print the information on the stock
            //---------------------------------------------------------------------------------------------------------------------------------------------
            
            print(infoSummary)
            
//            print("-------------------------------")
//            print("Stock Name:  ",infoTicker)
//            print("-------------------------------")
//            print("Exchange:    ",infoExchange)
//            print("-------------------------------")
//            print("Currently:   ",infoCurrentDate)
//            print("Price is:    ",infoCurrentPrice)
//            print("-------------------------------")
//            print("At Closing:  ",infoClosingDate)
//            print("Price is:    ",infoClosingPrice)
//            print("Change:      ",infoClosingChange,"  ",infoClosingPercent,"%")
//            print("Yield:       ",infoYield,"%")
//            print("-------------------------------")
            
            
//            // The first element
//            
//            guard let tickerData = allTickerData.first as? [String : AnyObject] else {
//                print("Could not convert to dictornary")
//                return
//            }
//            
//            print("Date of ticker data is: \(tickerData["lt"])")
//            
//            // Obtain the data
//            guard let date = tickerData["lt"] as? String else {
//                print("Could not obtain the date from the tickerData dictionary")
//                return
//            }
//            
//            print(date)

            
            
            
//            // Iterate over each object in the JSON
//            // Cast it to a dictionary
//            // Find what cooling centre is closest to my current location
//            for eachCoolingCentre in allTickerData {
//                
//                // Try to cast the current anyObject in the array of AnyObjects to a dictionary
//                if let thisCentre = eachCoolingCentre as? [String : AnyObject] {
//                    
//                    // A successful cast...
//                    //
//                    // Now try casting key values to see if this cooling centre is closest
//                    // to the current location
//                    guard let centreLongitude : Double = thisCentre["lon"] as? Double,
//                        let centreLatitude : Double = thisCentre["lat"]  as? Double,
//                        var centreName : String = thisCentre["locationName"] as? String,
//                        let centreDescription : String = thisCentre["locationDesc"] as? String
//                        else {
//                            print("Problem getting details for a centre")
//                            return
//                    }
//                    
//                    // Fix up the centre's name
//                    if centreDescription == "Library" {
//                        centreName += " "
//                        centreName += centreDescription
//                    }
//                    
//                    
//                    // Get the distance of this centre from my current location
//                    let distanceFromMe : Double = currentLocationDistanceTo(otherLatitude: centreLatitude, otherLongitude: centreLongitude)
//                    
//                    // See if this is the closest
//                    if distanceFromMe < shortestCoolingCentreDistance {
//                        
//                        // Save the closest centre
//                        shortestCoolingCentreDistance = distanceFromMe
//                        
//                        // Save closest centre basic details
//                        closestCoolingCentre["name"] = centreName
//                        closestCoolingCentre["latitude"] = String(centreLatitude)
//                        closestCoolingCentre["longitude"] = String(centreLongitude)
//                        
//                        // Debug output
//                        print("==== ***** NEW CLOSEST LOCATION ***** ====")
//                        for (key, value) in closestCoolingCentre {
//                            print("\(key): \(value)")
//                        }
//                        print("==== ******************************** ====")
//                        
//                        // Get further details for the closest centre
//                        guard let centreAddress : String = thisCentre["address"] as? String,
//                            //let centreNotes : String = thisCentre["notes"] as? String,
//                            var centrePhone : String = thisCentre["phone"] as? String
//                            else {
//                                print("Problem getting further details for the closest centre")
//                                return
//                        }
//                        
//                        // Fix up the centre's phone number
//                        if centrePhone == "<null>" {
//                            centrePhone = ""
//                        }
//                        
//                        // Save in a global variable (dictionary) that tracks the details of the closest centre
//                        //closestCoolingCentre["notes"] = centreNotes
//                        closestCoolingCentre["phone"] = centrePhone
//                        closestCoolingCentre["address"] = centreAddress
//                        
//                    }
//                    
//                    // Now we have the current longitude and latitude of this centre as double values
//                    print("==== information for \(centreName) ==== ")
//                    print("Longitude: \(centreLongitude)")
//                    print("Latitude: \(centreLatitude)")
//                    print("Distance from me: \(distanceFromMe)")
//                    print("====")
//                    
//                }
            
//            }
//            
//            // Print out the closest cooling centre details
//            print("==== ***** THE CLOSEST LOCATION IS... ***** ====")
//            for (key, value) in closestCoolingCentre {
//                print("\(key): \(value)")
//            }
//            print("==== ************************************** ====")
//            
//            // Now we can update the UI
//            // (must be done asynchronously)
//            DispatchQueue.main.async {
//                
//                var infoToShow : String = "==== ***** THE CLOSEST LOCATION IS... ***** ====\n"
//                for (key, value) in self.closestCoolingCentre {
//                    infoToShow += "\(key): \(value)\n"
//                }
//                infoToShow += "==== ************************************** ====\n"
//                
//                // Set the closest cooling station
//                if self.debugOutput == true {
//                    self.jsonResult.text = infoToShow
//                }
//                
//                // Set the name of the closest cooling station
//                guard let coolingCentreName = self.closestCoolingCentre["name"] else {
//                    print("Could not set the cooling centre name.")
//                    return
//                }
//                self.stationName.text = coolingCentreName
//                self.stationName.textColor = UIColor.black
//                
//                // Set the address of the closest cooling station so that it is clickable
//                guard var fullAddress = self.closestCoolingCentre["address"] else {
//                    print("Could not set the address.")
//                    return
//                }
//                fullAddress += ", Toronto, Ontario"
//                self.address.text = fullAddress
//                self.address.textColor = UIColor.black
//                
//                // Set the phone number of the closest cooling station so that it is clickable
//                self.phoneNumber.text = self.closestCoolingCentre["phone"]
//                self.phoneNumber.textColor = UIColor.black
//                
//                // Set up the map to show the closest cooling centre
//                guard let coolingCentreLatitude = CLLocationDegrees(self.closestCoolingCentre["latitude"]!),
//                    let coolingCentreLongitude = CLLocationDegrees(self.closestCoolingCentre["longitude"]!) else {
//                        print("Problem setting up the map.")
//                        return
//                }
//                
//                // Position the map
//                let coolingCentreCoordinates = CLLocationCoordinate2D(latitude: coolingCentreLatitude, longitude: coolingCentreLongitude + 0.001)
//                self.map.setCenter(coolingCentreCoordinates, animated: true)
//                let region = MKCoordinateRegion(center: coolingCentreCoordinates, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
//                self.map.setRegion(region, animated: true)
//                
//                // Add a pin at the location of the cooling centre
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = CLLocationCoordinate2D(latitude: coolingCentreLatitude, longitude: coolingCentreLongitude - 0.0001)
//                self.map.addAnnotation(annotation)
            
//            }
            
        } catch let error as NSError {
            
            print ("Failed to load: \(error.localizedDescription)")
            
        }
        
    }
    
    // Set up and begin an asynchronous request for JSON data
    func getMyJSON() {
                
        // Define a URL to retrieve a JSON file from
        let address : String = "https://www.google.com/finance/info?q=NASDAQ:AAPL"
        
        // Try to make a URL request object
        if let url = URL(string: address) {
            
            // We have an valid URL to work with
            print(url)
            
            // Now we create a URL request object
            let urlRequest = URLRequest(url: url)
            
            // Now we need to create an NSURLSession object to send the request to the server
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            // Now we create the data task and specify the completion handler
            let task = session.dataTask(with: urlRequest) {
                (data, response, error) in
                
                // Cast the NSURLResponse object into an NSHTTPURLResponse objecct
                if let r = response as? HTTPURLResponse {
                    
                    // If the request was successful, parse the given data
                    if r.statusCode == 200 {
                        
                        if let d = data {
                            
                            // Parse the retrieved data
                            self.parseMyJSON(d)
                            
                        }
                        
                    }
                    
                }
            }
            // Finally, we tell the task to start (despite the fact that the method is named "resume")
            task.resume()
            
        } else {
            
            // The NSURL object could not be created
            print("Error: Cannot create the NSURL object.")
            
        }
        
    }
    
    // This is the method that will run as soon as the view controller is created
    override func viewDidLoad() {
        
        // Sub-classes of UIViewController must invoke the superclass method viewDidLoad in their
        // own version of viewDidLoad()
        super.viewDidLoad()
        
        // Get the financial data
        getMyJSON()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
