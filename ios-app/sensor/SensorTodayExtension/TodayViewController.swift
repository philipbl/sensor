//
//  TodayViewController.swift
//  SensorTodayExtension
//
//  Created by Philip Lundrigan on 9/21/15.
//  Copyright © 2015 Philip Lundrigan. All rights reserved.
//

import UIKit
import NotificationCenter
import SensorFramework

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var currentHumidity: UILabel!
    
    var sensorData : SensorData = SensorData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        update()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        // TODO: Look into this

        completionHandler(NCUpdateResult.NewData)
    }
    
    @IBAction func launchApp(sender: AnyObject) {
        extensionContext?.openURL(NSURL(string: "sensor://")!, completionHandler: nil)
    }
    
    private func update() {
        func update(tempData: [String: Double], humData: [String: Double]) -> () {
            let tCurrent = tempData["current"]!
            let hCurrent = humData["current"]!
            
            dispatch_async(dispatch_get_main_queue()) {
                self.currentTemperature.text = tCurrent.formatString + "°"
                
                self.currentHumidity.text = hCurrent.formatString + "%"
            }
        }
        
        sensorData.getSummary(update, errorHandler: { print($0) })
    }
    
}

extension Double {
    var formatString: String { return String(format: "%.01f", self) }
}
