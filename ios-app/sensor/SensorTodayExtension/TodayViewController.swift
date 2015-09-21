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
    @IBOutlet weak var updateLabel: UILabel!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let updateTimeKey = "lastUpdated"
    let temperatureKey = "temperature"
    let humidityKey = "humidity"
    
    let sensorData : SensorData = SensorData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetMarginInsetsForProposedMarginInsets(var defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        defaultMarginInsets.bottom = 10.0
        return defaultMarginInsets
    }
    
    @IBAction func launchApp(sender: AnyObject) {
        extensionContext?.openURL(NSURL(string: "sensor://")!, completionHandler: nil)
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        getTime({
            self.userDefaults.setObject($0, forKey: self.updateTimeKey)
            self.displayTime($0)
        })
        
        getData({ temperature, humidity in
            self.userDefaults.setDouble(temperature, forKey: self.temperatureKey)
            self.userDefaults.setDouble(humidity, forKey: self.humidityKey)
            
            self.displayData(temperature, humidity: humidity)
            completionHandler(NCUpdateResult.NewData)
        })
    }
    
    private func displayData(temperature: Double, humidity: Double) {
        dispatch_async(dispatch_get_main_queue()) {
            self.currentTemperature.text = temperature.formatString + "°"
            self.currentHumidity.text = humidity.formatString + "%"
        }
    }
    
    private func displayTime(date: NSDate) {
        dispatch_async(dispatch_get_main_queue()) {
            self.updateLabel.text = "Updated \(self.getTimeDiffLabel(NSDate(), oldDate: date)) ago"
        }
    }
    
    private func getTime(completionHandler: (NSDate) -> ()) {
        let lastUpdated = userDefaults.objectForKey(updateTimeKey) as? NSDate
        
        if let lastUpdated = lastUpdated {
            let diff = NSDate().timeIntervalSinceDate(lastUpdated)
            
            if diff < 60 {
                print("getting time from storage")
                completionHandler(lastUpdated)
            }
            else {
                print("getting time from network")
                updateTime(completionHandler)
            }
        }
        else {
            print("getting time from network")
            updateTime(completionHandler)
        }
    }
    
    private func getData(completionHandler: (Double, Double) -> ()) {
        let lastUpdated = userDefaults.objectForKey(updateTimeKey) as? NSDate
        let temperature = userDefaults.doubleForKey(temperatureKey)
        let humidity = userDefaults.doubleForKey(humidityKey)
        
        
        if let lastUpdated = lastUpdated {
            let diff = NSDate().timeIntervalSinceDate(lastUpdated)
            
            if diff < 60 {
                print("getting data from storage")
                completionHandler(temperature, humidity)
            }
            else {
                print("getting data from network")
                updateData(completionHandler)
            }
        }
        else {
            print("getting data from network")
            updateData(completionHandler)
        }
    }
    
    private func updateData(completionHandler: (Double, Double) -> ()) {
        sensorData.getSummary({ completionHandler($0["current"]!, $1["current"]!)} , errorHandler: { print($0) })
    }
    
    private func updateTime(completionHandler: (NSDate) -> ()) {
        sensorData.getStatus(completionHandler, errorHandler: { print($0) })
    }
    
    private func getTimeDiffLabel(newDate: NSDate, oldDate: NSDate?) -> String {
        
        if let oldDate = oldDate {
            let diff = newDate.timeIntervalSinceDate(oldDate)
            
            if round(diff) == 1 {
                return "1 second"
            }
            
            else if diff < 60 {
                return "\(Int(round(diff))) seconds"
            }
            
            let minDiff = diff / 60
            
            if round(minDiff) == 1 {
                return "1 minute"
            }
            else if minDiff < 60 {
                return "\(Int(round(minDiff))) minutes"
            }
                
            let hourDiff = minDiff / 60
            
            if round(hourDiff) == 60 {
                return "1 hour"
            }
            else {
                return "\(Int(round(hourDiff))) hours"
            }
        }
        else {
            return "moments"
        }
    }
}

extension Double {
    var formatString: String { return String(format: "%.01f", self) }
}
