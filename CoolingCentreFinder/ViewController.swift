//  ViewController.swift
//  Market Watch
//  Created by Oscar Peters


import UIKit
import Foundation


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
    
    //**********************************************************************************************************

    @IBOutlet weak var output: UILabel!

    //**********************************************************************************************************

    @IBOutlet weak var input: UITextField!   // the ticker name goes here
    @IBOutlet weak var input2: UITextField!  // the exchange name goes here

    //**********************************************************************************************************

    @IBAction func action(_ sender: UIButton) {
        
//        output.text = "Requesting: " + (input.text)!
        
        // at this point, input input.text stores a string of a ticker name on the NASDAQ exchange
        
        var InputString : String
        InputString = (input.text)!
        
        var InputString2 : String
        InputString2 = (input2.text)!
        

        print(ImportantText)

        print("DEBUG:  Entering:  getMyJSON()")
        getMyJSON(SearchTickerName: InputString.uppercased(),SearchExchangeName: InputString2.uppercased())
        print("DEBUG:  Returned from:  getMyJSON()")
        
        print(ImportantText)
        
        output.text = ImportantText

        
    }
    
    //**********************************************************************************************************

    var ImportantText : String = "Welcome"
    
    // Whether to show debug output from JSON retrieval

    //**********************************************************************************************************

    var debugOutput : Bool = false

    //**********************************************************************************************************

    // Views that need to be accessible to all methods

    let jsonResult = UILabel()

    //**********************************************************************************************************

    // Set up and begin an asynchronous request for JSON data
    func getMyJSON(SearchTickerName : String,SearchExchangeName : String){
        
        print("DEBUG:  getMyJSON()")
        
        // Define a URL to retrieve a JSON file from
        let address : String = "https://www.google.com/finance/info?q="+SearchExchangeName+":"+SearchTickerName
        
        // Try to make a URL request object
        if let url = URL(string: address) {
            
            // We have an valid URL to work with
            print("DEBUG:  Interpreting the following URL:    ")
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
            return

        }

        return
        
    } // getMyJSON()

    //**********************************************************************************************************

    // If data is successfully retrieved from the server, we can parse it here
    func parseMyJSON(_ theData : Data){
        
        print("DEBUG:  parseMyJSON()")
        
        // Print the provided data
        // print("")
        // print("====== the data provided to parseMyJSON is as follows ======")
        // print(theData)
        
        // Convert the data into a String (this will get rid of the "//" in front of the API data)
        guard var rawDataAsString = String(data: theData, encoding: .utf8) else {
            print("could not convert data to string")
            return
        }
        rawDataAsString.remove(at: rawDataAsString.startIndex)
        rawDataAsString.remove(at: rawDataAsString.startIndex)
        rawDataAsString.remove(at: rawDataAsString.startIndex)
        rawDataAsString.remove(at: rawDataAsString.startIndex)

        // print(rawDataAsString)
        
        guard let fixedData = rawDataAsString.data(using: .utf8) else {
            print("Could not convert back into an object of type Data")
            return
        }
        
        // De-serializing JSON can throw errors, so should be inside a do-catch structure
        do {
            
            //------------------------------------------------------------------------------------
            // JSON de-serialization:
            //------------------------------------------------------------------------------------
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
            //------------------------------------------------------------------------------------
            
            let allTickerData = try JSONSerialization.jsonObject(with: fixedData, options: JSONSerialization.ReadingOptions.allowFragments) as! [AnyObject]

            //------------------------------------------------------------------------------------
            // DEBUG:  Print the entire contents of the JSON
            //------------------------------------------------------------------------------------
            //            print(allTickerData)
            //            print("\n Processing information from website...\n")
            
            //------------------------------------------------------------------------------------
            // Obtain the "first" database entry of the JSON (only going to have 1 content; searching a single stock now; could search multiple later)
            //------------------------------------------------------------------------------------
            
            guard let tickerData = allTickerData.first as? [String : AnyObject] else {
                print("Could not convert to dictornary")
                return
            }
            
            //------------------------------------------------------------------------------------
            // From "tickerData" entry, obtain the desired information on the stock
            //------------------------------------------------------------------------------------

            guard let infoTicker = tickerData["t"] as? String else {
                print("Could not obtain the name of the stock")
                return
            }
            guard let infoExchange = tickerData["e"] as? String else {
                print("Could not obtain the exchange of the stock")
                return
            }
//            guard let infoCurrentDate = tickerData["lt"] as? String else {
//            print("Could not obtain the current date of the stock")
//                return
//            }
//            guard let infoCurrentPrice = tickerData["el"] as? String else {
//            print("Could not obtain the current price of the stock");
//                return            }
            guard let infoClosingDate = tickerData["lt"] as? String else {
                print("Could not obtain the closing date of the stock")
                return
            }
            guard let infoClosingPrice = tickerData["l"] as? String else {
                print("Could not obtain the closing price of the stock")
                return
            }
//            guard let infoClosingChange = tickerData["c"] as? String else {
//                print("Could not obtain the change in price of the stock")
//                return
//            }
//            guard let infoClosingPercent = tickerData["cp"] as? String else {
//                print("Could not obtain the percent change of the stock")
//                return
//            }
//            guard let infoYield = tickerData["yld"] as? String else {
//               print("Could not obtain the yield of the stock")
//              return
//          }

            //---------------------------------------------------------
            // Store the information as a single string (using newlines) so it's easier dump later to text field as output
            //---------------------------------------------------------

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
//            infoSummary += "\n"
//            infoSummary += "Currently:   "
//            infoSummary += infoCurrentDate
//            infoSummary += "\n"
//            infoSummary += "Price is:    "
//            infoSummary += infoCurrentPrice
//            infoSummary += "\n"
            infoSummary += "-------------------------------"
            infoSummary += "\n"
            infoSummary += "At Closing:  "
            infoSummary += infoClosingDate
            infoSummary += "\n"
            infoSummary += "Price is:    "
            infoSummary += infoClosingPrice
            infoSummary += "\n"
//            infoSummary += "Change:      "
//            infoSummary += infoClosingChange
//            infoSummary += "  "
//            infoSummary += infoClosingPercent
//            infoSummary += "%"
//            infoSummary += "\n"
//            infoSummary += "Yield:       "
//            infoSummary += infoYield
//            infoSummary += "%"
//            infoSummary += "\n"
            infoSummary += "-------------------------------"
//            infoSummary += "\n"

            //---------------------------------------------------------
            // Print the information on the stock
            //---------------------------------------------------------
            
            print(infoSummary)
            
            output.text = infoTicker + " * " + infoExchange + " * " + infoClosingPrice + " * " + infoClosingDate

            return
            
        } catch let error as NSError {
            
            print ("Failed to load: \(error.localizedDescription)")
            
            return
        
        }
        
    } // parseMyJSON()

    //**********************************************************************************************************
    
    // This is the method that will run as soon as the view controller is created

    override func viewDidLoad() {
        
        // Sub-classes of UIViewController must invoke the superclass method viewDidLoad in their
        // own version of viewDidLoad()
        super.viewDidLoad()
        
        print("Program is a go")
        
        // Get the financial data
        // getMyJSON(SearchTickerName: "AAPL")
    }

    //**********************************************************************************************************

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //**********************************************************************************************************
    
} // ViewController


