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


func getStatus(successHandler: (NSDate) -> (), errorHandler: (String) -> ()) {
    func success(data: JSON) {
        let lastReading = data["last_reading"].doubleValue
        let date = NSDate(timeIntervalSince1970: lastReading / 1000)
        
        successHandler(date)
    }
    
    download("sensor/status", success) { errorHandler($0) }
}

func getSummary(successHandler: ([String: Double], [String: Double]) -> (), errorHandler: (String) -> ()) {
    func success(data: JSON) {
        let newHumData = convertData(data["humidity"])
        let newTempData = convertData(data["temperature"])
        
        successHandler(newTempData, newHumData)
    }
    
    download("sensor/summary?duration=1440", success) { errorHandler($0) }
}

func getTwelveHourData() {
    
}

func getTwentyFourHourData() {
    
}

func getAverageWeekData(successHandler: ([String: Double]) -> (), errorHandler: (String) -> ()) {
    func success(data: JSON) {
        let newData = convertData(data)
        
        successHandler(newData)
    }
    
    download("sensor/average/week", success) { errorHandler($0) }
}

func getAverageDayData(successHandler: ([String: Double]) -> (), errorHandler: (String) -> ()) {
    func success(data: JSON) {
        let newData = convertData(data)
        
        successHandler(newData)
    }
    
    download("sensor/average/day", success) { errorHandler($0) }
}

private func convertData(data: JSON) -> [String: Double] {
    var newData = [String: Double]()
    
    for (key: String, subJson: JSON) in data {
        newData[key] = subJson.doubleValue
    }
    
    return newData
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


