    //
//  ViewController.swift
//  sensor
//
//  Created by Philip Lundrigan on 9/2/15.
//  Copyright (c) 2015 Philip Lundrigan. All rights reserved.
//

import UIKit
import Charts

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeStatusView()
        makeSummaryView()
        graphPickerChanged()
    }
    
    @IBAction func graphPickerChanged() {
        switch graphPicker.selectedSegmentIndex {
        case 0:
            makeHourView()
        case 1:
            makeTwelveHourView()
        case 2:
            makeTwentyFourHourView()
        case 3:
            makeWeekView()
        case 4:
            makeMonthView()
        default:
            break
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
        
        runNetworkCommand(sensorData.getStatus, success: update, failure: { println($0) })
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
                self.maxTemperature.text = "High: " + tMax.formatString + "°"
                self.minTemperature.text = "Low: " + tMin.formatString + "°"
                
                self.currentHumidity.text = hCurrent.formatString + "%"
                self.maxHumidity.text = "High: " + hMax.formatString + "%"
                self.minHumidity.text = "Low: " + hMin.formatString + "%"
            }
        }
        
        runNetworkCommand(sensorData.getSummary, success: update, failure: { println($0) })
    }
    
    private func makeHourView() {
        func update(data: [String: [AnyObject]]) -> () {
            createGraph(graphView,
                data["humidity"] as! [Double],
                data["temperature"] as! [Double],
                data["labels"] as! [NSDate])
        }
        
        runNetworkCommand(sensorData.getHourData, success: update, failure: { println($0) })
    }
    
    private func makeTwelveHourView() {
        func update(data: [String: [AnyObject]]) -> () {
            createGraph(graphView,
                data["humidity"] as! [Double],
                data["temperature"] as! [Double],
                data["labels"] as! [NSDate])
        }
        
        runNetworkCommand(sensorData.getTwelveHourData, success: update, failure: { println($0) })
    }
    
    private func makeTwentyFourHourView() {
        func update(data: [String: [AnyObject]]) -> () {
            createGraph(graphView,
                data["humidity"] as! [Double],
                data["temperature"] as! [Double],
                data["labels"] as! [NSDate])
        }
        
        runNetworkCommand(sensorData.getTwentyFourHourData, success: update, failure: { println($0) })
    }
    
    private func makeWeekView() {
        func update(data: [String: [AnyObject]]) -> () {
            createGraph(graphView,
                data["humidity"] as! [Double],
                data["temperature"] as! [Double],
                data["labels"] as! [NSDate])
        }
        
        runNetworkCommand(sensorData.getWeekData, success: update, failure: { println($0) })
    }
    
    private func makeMonthView() {
        func update(data: [String: [AnyObject]]) -> () {
            createGraph(graphView,
                data["humidity"] as! [Double],
                data["temperature"] as! [Double],
                data["labels"] as! [NSDate])
        }
        
        runNetworkCommand(sensorData.getMonthData, success: update, failure: { println($0) })
    }
    
    private func makeAverageDayView() {
        func update(data: [String: [AnyObject]]) -> () {
            createGraph(graphView,
                data["humidity"] as! [Double],
                data["temperature"] as! [Double],
                data["labels"] as! [String])
        }
        
        runNetworkCommand(sensorData.getAverageDayData, success: update, failure: { println($0) })
    }
    
    private func makeAverageWeekView() {
        func update(data: [String: [AnyObject]]) -> () {
            createGraph(graphView,
                data["humidity"] as! [Double],
                data["temperature"] as! [Double],
                data["labels"] as! [String])            
        }
        
        runNetworkCommand(sensorData.getAverageWeekData, success: update, failure: { println($0) })
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
