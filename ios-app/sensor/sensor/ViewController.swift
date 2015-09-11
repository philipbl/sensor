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
    
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var maxTemperature: UILabel!
    @IBOutlet weak var minTemperature: UILabel!
    
    @IBOutlet weak var currentHumidity: UILabel!
    @IBOutlet weak var maxHumidity: UILabel!
    @IBOutlet weak var minHumidity: UILabel!

    @IBOutlet weak var lineGraphView: LineChartView!
    @IBOutlet weak var lineGraphView2: LineChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // TODO: Only update if it is in the view
        updateSummaryView()
        updateAverageDayView()
        updateAverageWeekView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateStatusView() {
        // Update some label somewhere
    }
    
    private func updateSummaryView() {
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
            
            ViewController.networkActivity(false)
        }
        
        ViewController.networkActivity(true)
        getSummary(update) {
            ViewController.networkActivity(false)
            println($0)
        }
    }
    
    private func updateAverageDayView() {
        func update(data: [String: [AnyObject]]) -> () {
            createGraph(lineGraphView,
                data["humidity"] as! [Double],
                data["temperature"] as! [Double],
                data["labels"] as! [String])
            
            ViewController.networkActivity(false)
        }
        
        ViewController.networkActivity(true)
        getAverageDayData(update) {
            ViewController.networkActivity(false)
            println($0)
        }
    }
    
    private func updateAverageWeekView() {
        func update(data: [String: [AnyObject]]) -> () {
            createGraph(lineGraphView2,
                data["humidity"] as! [Double],
                data["temperature"] as! [Double],
                data["labels"] as! [String])
            
            ViewController.networkActivity(false)
        }
        
        ViewController.networkActivity(true)
        getAverageWeekData(update) {
            ViewController.networkActivity(false)
            println($0)
        }
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
