//
//  SensorData.swift
//  sensor
//
//  Created by Philip Lundrigan on 9/2/15.
//  Copyright (c) 2015 Philip Lundrigan. All rights reserved.
//

import Foundation

class SensorData {
//    let baseURL = "http://localhost:5000/"
    let baseURL = "https://still-sands-8003.herokuapp.com/"
    
    var cachedData = [String:JSON]()

    func getStatus(successHandler: (NSDate) -> (), errorHandler: (String) -> ()) {
        func success(data: JSON) {
            let lastReading = data["last_reading"].doubleValue
            let date = convertDate(lastReading)
            
            successHandler(date)
        }
        
        download("sensor/status", successHandler: success, errorHandler: { errorHandler($0) }, cache: false)
    }

    func getSummary(successHandler: ([String: Double], [String: Double]) -> (), errorHandler: (String) -> ()) {
        func convertData(data: JSON) -> [String: Double] {
            var newData = [String: Double]()
            
            for (key, subJson): (String, JSON) in data {
                newData[key] = subJson.doubleValue
            }
            
            return newData
        }
        
        func success(data: JSON) {
            let newHumData = convertData(data["humidity"])
            let newTempData = convertData(data["temperature"])
            
            successHandler(newTempData, newHumData)
        }
        
        download(
            "sensor/summary?duration=1440",
            successHandler: success,
            errorHandler: { errorHandler($0) },
            cache: false
        )
    }
    
    func getHourData(successHandler: ([String: [AnyObject]]) -> (), errorHandler: (String) -> ()) {
        download(
            "sensor/stats/minutes?duration=60",
            successHandler: { successHandler(self.convertDictData($0)) },
            errorHandler: { errorHandler($0) }
        )
    }
    
    func getTwelveHourData(successHandler: ([String: [AnyObject]]) -> (), errorHandler: (String) -> ()) {
        download(
            "sensor/stats/minutes?duration=720&interval=15",
            successHandler: { successHandler(self.convertDictData($0)) },
            errorHandler: { errorHandler($0) }
        )
    }
    
    func getTwentyFourHourData(successHandler: ([String: [AnyObject]]) -> (), errorHandler: (String) -> ()) {
        download(
            "sensor/stats/minutes?duration=1440&interval=30",
            successHandler: { successHandler(self.convertDictData($0)) },
            errorHandler: { errorHandler($0) }
        )
    }
    
    func getWeekData(successHandler: ([String: [AnyObject]]) -> (), errorHandler: (String) -> ()) {
        download(
            "sensor/stats/hours?duration=168&interval=3",
            successHandler: { successHandler(self.convertDictData($0)) },
            errorHandler: { errorHandler($0) }
        )
    }
    
    func getMonthData(successHandler: ([String: [AnyObject]]) -> (), errorHandler: (String) -> ()) {
        download(
            "sensor/stats/hours?duration=720&interval=12",
            successHandler: { successHandler(self.convertDictData($0)) },
            errorHandler: { errorHandler($0) }
        )
    }
    
    func getAverageWeekData(successHandler: ([String: [AnyObject]]) -> (), errorHandler: (String) -> ()) {
        func success(data: JSON) {
            let newData = ["temperature": convertArrayData(data["temperature"]) { $0.doubleValue },
                "humidity": convertArrayData(data["humidity"]) { $0.doubleValue },
                "labels": convertArrayData(data["labels"]) { $0.stringValue }]
            
            successHandler(newData)
        }
        
        download("sensor/average/week", successHandler: success, errorHandler: { errorHandler($0) })
    }
    
    func getAverageDayData(successHandler: ([String: [AnyObject]]) -> (), errorHandler: (String) -> ()) {
        func success(data: JSON) {
            let newData = ["temperature": convertArrayData(data["temperature"]) { $0.doubleValue },
                "humidity": convertArrayData(data["humidity"]) { $0.doubleValue },
                "labels": convertArrayData(data["labels"]) { $0.stringValue }]
            
            successHandler(newData)
        }
        
        download("sensor/average/day", successHandler: success, errorHandler: { errorHandler($0) })
    }
    
    private func convertDictData(data: JSON) -> [String: [AnyObject]] {
        let humidityArray = data["humidity"].arrayValue
        let temperatureArray = data["temperature"].arrayValue
        
        let humidityData = humidityArray.map({ data in
            return data["y"].doubleValue
        })
        
        let temperatureData = temperatureArray.map({ data in
            return data["y"].doubleValue
        })
        
        let labels = temperatureArray.map({ data in
            return self.convertDate(data["x"].doubleValue)
        })
        
        return ["temperature": temperatureData, "humidity": humidityData, "labels": labels]
    }
    
    private func convertArrayData(data: JSON, converter: (JSON) -> AnyObject) -> [AnyObject] {
        var list = [AnyObject]()
        
        for (_, subJson): (String, JSON) in data {
            list.append(converter(subJson))
        }
        
        return list
    }
    
    private func convertDate(date: Double) -> NSDate {
        return NSDate(timeIntervalSince1970: date / 1000)
    }
    
    private func download(urlString: String, successHandler: (JSON) -> (), errorHandler: (String) -> (), cache: Bool = true) {
        if let data = cachedData[urlString] {
            successHandler(data)
            return
        }

        let url = NSURL(string: baseURL + urlString)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            if let httpResponse = response as? NSHTTPURLResponse {
                
                if httpResponse.statusCode == 200 {
                    let json = JSON(data: data!)
                    
                    if cache {
                        self.cachedData[urlString] = json
                    }

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

