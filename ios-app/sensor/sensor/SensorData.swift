//
//  SensorData.swift
//  sensor
//
//  Created by Philip Lundrigan on 9/2/15.
//  Copyright (c) 2015 Philip Lundrigan. All rights reserved.
//

import Foundation
//import SwiftyJSON

var baseURL = "http://localhost:5000/"

class SensorData {
    
    func getStatus(successHandler: (NSDate) -> (), errorHandler: (String) -> ()) {
        func success(data: JSON) {
            let lastReading = data["last_reading"].doubleValue
            let date = NSDate(timeIntervalSince1970: lastReading / 1000)
            
            successHandler(date)
        }
        
        download("sensor/status", successHandler: success) { errorHandler($0) }
    }
    
    func getSummary(successHandler: ([String: Double], [String: Double]) -> (), errorHandler: (String) -> ()) {
        func success(data: JSON) {
            let humData = data["humidity"]
            let tempData = data["temperature"]
            
            var newTempData = [String: Double]()
            var newHumData = [String: Double]()
            
            newHumData["current"] = humData["current"].doubleValue
            newHumData["min"] = humData["min"].doubleValue
            newHumData["max"] = humData["max"].doubleValue
            
            newTempData["current"] = tempData["current"].doubleValue
            newTempData["min"] = tempData["min"].doubleValue
            newTempData["max"] = tempData["max"].doubleValue
            
            successHandler(newTempData, newHumData)
        }
        
        download("sensor/summary?duration=1440", successHandler: success) { errorHandler($0) }
    }
    
    func getTwelveHourData() {
        
    }
    
    func getTwentyFourHourData() {
        
    }
    
    private func download(url: String, successHandler: (JSON) -> (), errorHandler: (String) -> ()) {
        let url = NSURL(string: baseURL + url)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            if let httpResponse = response as? NSHTTPURLResponse {
                
                if httpResponse.statusCode == 200 {
                    let json = JSON(data: data)
                    successHandler(json)
                }
                else {
                    errorHandler("Error with URL.")
                }
            }
            else {
                errorHandler("Error reaching server.")
            }
        }
        
        task.resume()
    }
    
    
}
