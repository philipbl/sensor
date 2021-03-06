//
//  Graphs.swift
//  sensor
//
//  Created by Philip Lundrigan on 9/3/15.
//  Copyright (c) 2015 Philip Lundrigan. All rights reserved.
//

import Foundation
import Charts


func createGraph(view: LineChartView, humidityData: [Double], temperatureData: [Double], labels: [NSDate]) {
    createGraph(view, humidityData: humidityData, temperatureData: temperatureData, labels: datesToLabels(labels))
}

func createGraph(view: LineChartView, humidityData: [Double], temperatureData: [Double], labels: [String]) {
    func configureDataSet(dataSet: LineChartDataSet, color: UIColor) {
        dataSet.drawCircleHoleEnabled = false;
        dataSet.lineWidth = 2.0;
        dataSet.circleRadius = 3.0;
        dataSet.setColor(color)
        dataSet.setCircleColor(color)
        dataSet.drawCubicEnabled = true
    }
    
    // Convert from Double to ChartDataEntry
    let humData = humidityData.enumerate().map { (index, value) in
        return ChartDataEntry(value: value, xIndex: index)
    }
    
    let tempData = temperatureData.enumerate().map { (index, value) in
        return ChartDataEntry(value: value, xIndex: index)
    }
    
    // Create data sets
    let humDataSet = LineChartDataSet(yVals: humData, label: "Humidity")
    let tempDataSet = LineChartDataSet(yVals: tempData, label: "Temperature")
    
    // Configure colors and other parameters
    configureDataSet(humDataSet, color: UIColor(red: 3/255.0, green: 169/255.0, blue: 244/255.0, alpha: 1.0))
    configureDataSet(tempDataSet, color: UIColor(red: 244/255.0, green: 67/255.0, blue: 54/255.0, alpha: 1.0))

    let chartData = LineChartData(xVals: labels, dataSets: [humDataSet, tempDataSet])
    view.data = chartData
    
    // Configure other parameters about the graph
    view.descriptionText = ""
    view.rightAxis.enabled = false
    view.legend.enabled = false
    view.leftAxis.startAtZeroEnabled = false;
    view.xAxis.labelPosition = .Bottom
    view.xAxis.drawGridLinesEnabled = false;
    view.drawGridBackgroundEnabled = false;
    
    
    // TODO: Adjust zoom everytime someone creates a new graph
    // TODO: Initial yaxis starts at zero
}

func datesToLabels(dates: [NSDate]) -> [String] {
    // If time difference is 23 hours or less, X:XX XM format
    // If time spans a day, put day in 12:00 AM label
    
    // If time difference is 24 hours or more, use MMM DD format
    
    let formatter = NSDateFormatter()
    formatter.timeStyle = .ShortStyle
    

    return dates.map({ date in
        return formatter.stringFromDate(date)
    })
}
