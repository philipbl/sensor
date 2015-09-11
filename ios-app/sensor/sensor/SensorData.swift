//
//  SensorData.swift
//  sensor
//
//  Created by Philip Lundrigan on 9/2/15.
//  Copyright (c) 2015 Philip Lundrigan. All rights reserved.
//

import Foundation
//import SwiftyJSON

//let baseURL = "http://localhost:5000/"
let baseURL = "https://still-sands-8003.herokuapp.com/"


func getStatus(successHandler: (NSDate) -> (), errorHandler: (String) -> ()) {
    func success(data: JSON) {
        let lastReading = data["last_reading"].doubleValue
        let date = NSDate(timeIntervalSince1970: lastReading / 1000)
        
        successHandler(date)
    }
    
    download("sensor/status", success) { errorHandler($0) }
}

func getSummary(successHandler: ([String: Double], [String: Double]) -> (), errorHandler: (String) -> ()) {
    func convertData(data: JSON) -> [String: Double] {
        var newData = [String: Double]()
        
        for (key: String, subJson: JSON) in data {
            newData[key] = subJson.doubleValue
        }
        
        return newData
    }
    
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

func getAverageWeekData(successHandler: ([String: [AnyObject]]) -> (), errorHandler: (String) -> ()) {
    func success(data: JSON) {
        let newData = ["temperature": convertArrayData(data["temperature"]) { $0.doubleValue },
                       "humidity": convertArrayData(data["humidity"]) { $0.doubleValue },
                       "labels": convertArrayData(data["labels"]) { $0.stringValue }]
        
        successHandler(newData)
    }
    
    download("sensor/average/week", success) { errorHandler($0) }
}

func getAverageDayData(successHandler: ([String: [AnyObject]]) -> (), errorHandler: (String) -> ()) {
    func success(data: JSON) {
        let newData = ["temperature": convertArrayData(data["temperature"]) { $0.doubleValue },
                       "humidity": convertArrayData(data["humidity"]) { $0.doubleValue },
                       "labels": convertArrayData(data["labels"]) { $0.stringValue }]
        
        successHandler(newData)
    }
    
    download("sensor/average/day", success) { errorHandler($0) }
}

private func convertArrayData(data: JSON, converter: (JSON) -> AnyObject) -> [AnyObject] {
    var list = [AnyObject]()
    
    for (index: String, subJson: JSON) in data {
        list.append(converter(subJson))
    }
    
    return list
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


