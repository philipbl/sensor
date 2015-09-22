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
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        self.updateWidget()
    }
    
    func widgetMarginInsetsForProposedMarginInsets(var defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        defaultMarginInsets.bottom = 10.0
        return defaultMarginInsets
    }
    
    @IBAction func launchApp(sender: AnyObject) {
        extensionContext?.openURL(NSURL(string: "sensor://")!, completionHandler: nil)
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        print("widgetPerformUpdateWithCompletionHandler")
        if self.updateWidget() {
            completionHandler(NCUpdateResult.NewData)
        }
        else {
            completionHandler(NCUpdateResult.NoData)
        }
    }
    
    private func updateWidget() -> Bool {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateLabel.text = "Loading..."
        })
        
        return getData({ temperature, humidity, updated in
            self.userDefaults.setDouble(temperature, forKey: self.temperatureKey)
            self.userDefaults.setDouble(humidity, forKey: self.humidityKey)
            
            self.displayData(temperature, humidity: humidity)
            self.displayTime(updated)
        })
    }
    
    private func displayData(temperature: Double, humidity: Double) {
        dispatch_async(dispatch_get_main_queue(), {
            self.currentTemperature.text = temperature.formatString + "°"
            self.currentHumidity.text = humidity.formatString + "%"
        })
    }
    
    private func displayTime(date: NSDate) {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        let dateString = formatter.stringFromDate(date)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.updateLabel.text = "Updated " + dateString
        })
    }
    
    private func getData(completionHandler: (Double, Double, NSDate) -> ()) -> Bool {
        let lastUpdated = userDefaults.objectForKey(updateTimeKey) as? NSDate
        let temperature = userDefaults.doubleForKey(temperatureKey)
        let humidity = userDefaults.doubleForKey(humidityKey)
        
        if let lastUpdated = lastUpdated {
            let diff = NSDate().timeIntervalSinceDate(lastUpdated)
            
            print(diff)
            
            if diff < 60 {
                print("getting data from storage")
                completionHandler(temperature, humidity, lastUpdated)
                return false
            }
            else {
                print("getting data from network")
                updateData(completionHandler)
                return true
            }
        }
        else {
            print("getting data from network")
            updateData(completionHandler)
            return true
        }
    }
    
    private func updateData(completionHandler: (Double, Double, NSDate) -> ()) {
        let now = NSDate()
        self.userDefaults.setObject(now, forKey: self.updateTimeKey)
        
        sensorData.getSummary({ completionHandler($0["current"]!, $1["current"]!, now) } , errorHandler: { print($0) })
    }
}

extension Double {
    var formatString: String { return String(format: "%.01f", self) }
}
