//
//  ViewController.swift
//  sensor
//
//  Created by Philip Lundrigan on 9/2/15.
//  Copyright (c) 2015 Philip Lundrigan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var maxTemperature: UILabel!
    @IBOutlet weak var minTemperature: UILabel!
    
    @IBOutlet weak var currentHumidity: UILabel!
    @IBOutlet weak var maxHumidity: UILabel!
    @IBOutlet weak var minHumidity: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateSummaryView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSummaryView() {
        func update(tempData: [String: Double], humData: [String: Double]) -> () {
            let tCurrent = tempData["current"]!
            let tMax = tempData["max"]!
            let tMin = tempData["min"]!
            
            let hCurrent = humData["current"]!
            let hMax = humData["max"]!
            let hMin = humData["min"]!
            
            dispatch_async(dispatch_get_main_queue()) {
                self.currentTemperature.text = String(format: "%.01f°", tCurrent)
                self.maxTemperature.text = String(format: "%.01f°", tMax)
                self.minTemperature.text = String(format: "%.01f°", tMin)
                
                self.currentHumidity.text = String(format: "%.01f%%", hCurrent)
                self.maxHumidity.text = String(format: "%.01f%%", hMax)
                self.minHumidity.text = String(format: "%.01f%%", hMin)
            }
        }
        
        getSummary(update, { println($0) })
    }


}

