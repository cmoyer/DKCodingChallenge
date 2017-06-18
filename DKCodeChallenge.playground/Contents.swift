// ****************************************************
//  DKCodeChallenge.playground
//
//  Created by Chad Moyer on 6/17/17.
// ****************************************************
import UIKit

//MARK: Data Model

public class SwingSample {
    let timestamp: Int
    let ax: Double
    let ay: Double
    let az: Double
    let wx: Double
    let wy: Double
    let wz: Double
    
    init(timestamp: Int, ax: Double, ay: Double, az: Double,
         wx: Double, wy: Double, wz: Double) {
        self.timestamp = timestamp
        self.ax = ax
        self.ay = ay
        self.az = az
        self.wx = wx
        self.wy = wy
        self.wz = wz
    }
}

//MARK: Get data from csv file

var fullSwing: [SwingSample] = []

// Load the data from the provided csv file
if let url = Bundle.main.url(forResource: "latestSwing", withExtension: "csv") {
    do {
        let fileData = try String(contentsOf: url, encoding: .utf8)
        
        // Separate the file data into an array of values with each index being a line from the file
        let dataComponents = fileData.components(separatedBy: "\r")
        
        for data in dataComponents {
            // Separate the line of data into its respective columns
            let columns = data.components(separatedBy: ",")
            
            // Explicitly cast our column values to the respective data types
            let timestamp = Int(columns[0].replacingOccurrences(of: "\n", with: ""))
            let ax = Double(columns[1])
            let ay = Double(columns[2])
            let az = Double(columns[3])
            let wx = Double(columns[4])
            let wy = Double(columns[5])
            let wz = Double(columns[6])
            
            // Use our data to create a SwingSample. The parameters are implicitly unwrapped for this challenge only because we know that all of the values in the csv file are integers our doubles. In normal conditions, we would unwrap them safely using if-let statements
            let tmpSample = SwingSample.init(timestamp: timestamp!, ax: ax!, ay: ay!, az: az!, wx: wx!, wy: wy!, wz: wz!)
            
           fullSwing.append(tmpSample)
        }
    } catch {
        print (error)
    }
}

/*
 CM COMMENTS - REMOVE ME BEFORE SUBMITTING
 */

// This function will return the first index where data has values that are above the threshold value for at least winLength samples
func searchContinuityAboveValue(data: [Double], indexBegin: Int, indexEnd: Int, threshold: Double, winLength: Int) {
    
}

// This function will return the first index where data has values that are within the threshold range for at least winLength samples. 
// In this function, indexBegin will be larger than indexEnd
func backSearchContinuityWithinRange(data: [Double], indexBegin: Int, indexEnd: Int, thresholdLo: Double, thresholdHi: Double, winLength: Int) {
    
}

// This function will return the first index where both data1 and data2 have values that are above threshold1 and threshold2 respectively, for at least winLength samples.
func searchContinuityAboveValueTwoSignals(data1: [Double], data2: [Double], indexBegin: Int, indexEnd: Int, threshold1: Double, threshold2: Double, winLength: Int) {
    
}

// This function will return the startIndex and endIndex for ALL continuous samples where data is within the threshold range for at least winLength samples
func searchMultiContinuityWithinRange(data: [Double], indexBegin: Int, indexEnd: Int, thresholdLo: Double, thresholdHi: Double, winLength: Int) {
    
}



