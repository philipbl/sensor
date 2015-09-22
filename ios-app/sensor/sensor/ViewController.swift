    //
//  ViewController.swift
//  sensor
//
//  Created by Philip Lundrigan on 9/2/15.
//  Copyright (c) 2015 Philip Lundrigan. All rights reserved.
//

import UIKit
import Charts
import SensorFramework

class ViewController: UIViewController {
    static var setVisibleCalls = 0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateLabel: UILabel!
    
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var maxTemperature: UILabel!
    @IBOutlet weak var minTemperature: UILabel!
    
    @IBOutlet weak var currentHumidity: UILabel!
    @IBOutlet weak var maxHumidity: UILabel!
    @IBOutlet weak var minHumidity: UILabel!

    @IBOutlet weak var graphPicker: UISegmentedControl!
    @IBOutlet weak var graphView: LineChartView!
    
    var sensorData : SensorData = SensorData()
    
    var GlobalBackgroundQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeStatusView()
        makeSummaryView()
        graphPickerChanged()
        statusUpdater()
    }
    
    @IBAction func graphPickerChanged() {
        switch graphPicker.selectedSegmentIndex {
        case 0:
            makeTwelveHourView()
        case 1:
            makeTwentyFourHourView()
        case 2:
            makeWeekView()
        case 3:
            makeMonthView()
        default:
            break
        }
    }
    
    private func statusUpdater() {
        let delayInSeconds = 60.0
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        
        dispatch_after(delay, GlobalBackgroundQueue) {
            self.makeStatusView()
            self.makeSummaryView()
            
            self.statusUpdater()
        }
    }
    
    private func makeStatusView() {
        func update(date: NSDate) -> () {
            
            let formatter = NSDateFormatter()
            formatter.timeStyle = .ShortStyle
            let dateString = formatter.stringFromDate(date)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.updateLabel.text = "Updated: " + dateString
            }
        }
        
        runNetworkCommand(sensorData.getStatus, success: update, failure: { print($0) })
    }
    
    private func makeSummaryView() {
        func update(tempData: [String: Double], humData: [String: Double]) -> () {
            let tCurrent = tempData["current"]!
            let tMax = tempData["max"]!
            let tMin = tempData["min"]!
            
            let hCurrent = humData["current"]!
            let hMax = humData["max"]!
            let hMin = humData["min"]!
            
            dispatch_async(dispatch_get_main_queue()) {
                self.currentTemperature.text = tCurrent.formatString + "°"
                self.maxTemperature.text = tMax.formatString + "°"
                self.minTemperature.text = tMin.formatString + "°"
                
                self.currentHumidity.text = hCurrent.formatString + "%"
                self.maxHumidity.text = hMax.formatString + "%"
                self.minHumidity.text = hMin.formatString + "%"
            }
        }
        
        runNetworkCommand(sensorData.getSummary, success: update, failure: { print($0) })
    }
    
    private func makeHourView() {
        runNetworkCommand(sensorData.getHourData, success: updateGraph, failure: { print($0) })
    }
    
    private func makeTwelveHourView() {
        runNetworkCommand(sensorData.getTwelveHourData, success: updateGraph, failure: { print($0) })
    }
    
    private func makeTwentyFourHourView() {
        runNetworkCommand(sensorData.getTwentyFourHourData, success: updateGraph, failure: { print($0) })
    }
    
    private func makeWeekView() {
        runNetworkCommand(sensorData.getWeekData, success: updateGraph, failure: { print($0) })
    }
    
    private func makeMonthView() {
        runNetworkCommand(sensorData.getMonthData, success: updateGraph, failure: { print($0) })
    }
    
    private func makeAverageDayView() {
        runNetworkCommand(sensorData.getAverageDayData, success: updateGraph, failure: { print($0) })
    }
    
    private func makeAverageWeekView() {
        runNetworkCommand(sensorData.getAverageWeekData, success: updateGraph, failure: { print($0) })
    }
    
    private func updateGraph(data: [String: [AnyObject]]) {
        dispatch_async(dispatch_get_main_queue()) {
            createGraph(self.graphView,
                humidityData: data["humidity"] as! [Double],
                temperatureData: data["temperature"] as! [Double],
                labels: data["labels"] as! [NSDate])
        }
    }
    
    private func runNetworkCommand<S, T>(action: (S -> (), T -> ()) -> (), success: S -> (), failure: T -> ()) {
        func new_success(param: S) -> () {
            ViewController.networkActivity(false)
            success(param)
        }
        
        func new_failure(param: T) -> () {
            ViewController.networkActivity(false)
            failure(param)
        }
        
        ViewController.networkActivity(true)
        action(new_success, new_failure)
    }

    static func networkActivity(visible: Bool) {
        if visible {
            setVisibleCalls++
        }
        else {
            setVisibleCalls--
        }
        
        assert(setVisibleCalls >= 0, "Network Activity Indicator was asked to hide more often than shown")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = setVisibleCalls > 0
    }
}

extension Double {
    var formatString: String { return String(format: "%.01f", self) }
}
