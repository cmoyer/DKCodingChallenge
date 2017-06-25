import UIKit
import XCTest


//MARK: Data Model
public class FullSwing {
    let timestamp: [Int]
    let ax: [Double]
    let ay: [Double]
    let az: [Double]
    let wx: [Double]
    let wy: [Double]
    let wz: [Double]
    
    init(timestamp: [Int], ax: [Double], ay: [Double], az: [Double], wx: [Double], wy: [Double], wz: [Double]) {
        self.timestamp = timestamp
        self.ax = ax
        self.ay = ay
        self.az = az
        self.wx = wx
        self.wy = wy
        self.wz = wz
    }
}


//MARK: Validation functions for the parameters
func validateIndexRange(indexBegin: Int, indexEnd: Int) -> Bool {
    if indexBegin < 0 || indexEnd < 0 {
        return false
    } else if indexBegin == indexEnd {
        return false
    } else if indexBegin > indexEnd {
        return false
    } else {
        return true
    }
}

func validateBackIndexRange(indexBegin: Int, indexEnd: Int) -> Bool {
    if indexBegin < 0 || indexEnd < 0 {
        return false
    } else if indexBegin == indexEnd {
        return false
    } else if indexBegin < indexEnd {
        return false
    } else {
        return true
    }
}

func validateThresholdRange(thresholdLo: Double, thresholdHi: Double) -> Bool {
    if thresholdLo > thresholdHi {
        return false
    } else if thresholdLo == thresholdHi {
        return false
    } else {
        return true
    }
}

func validateWinLength(winLength: Int) -> Bool {
    return winLength > 0
}


//MARK: Function that checks if we are within our threshold range. If we only want to find values above a threshold and not within a range, we can specify the second value of the 'threshold' parameter as nil.
func withinThreshold(value: Double, threshold: (lo: Double, hi: Double?)) -> Bool {
    var predicate: NSPredicate
    if let thresholdHi = threshold.hi {
        predicate = NSPredicate(format: "SELF BETWEEN {\(threshold.lo), \(thresholdHi)}")
    } else {
        predicate = NSPredicate(format: "SELF > \(threshold.lo)")
    }
    
    return predicate.evaluate(with: value)
}

//withinThreshold(value: 3.5, threshold: (4.0, nil))

func searchContinuity(data: [Double], indexBegin: Int, indexEnd: Int, threshold: (lo: Double, hi: Double?), winLength: Int) -> (begin: Int, end: Int) {
    
    var winLengthCounter = 0
    var startIndex: Int?
    
    var i = indexBegin
    while i != indexEnd {
        if withinThreshold(value: data[i], threshold: threshold) {
            winLengthCounter += 1
            if startIndex == nil {
                startIndex = i
            }
        } else if winLengthCounter >= winLength {
            return (startIndex!, i) // we can force-unwrap the startIndex because it will have to have a value if the counter > the specificed winLength
        } else {
            winLengthCounter = 0
            startIndex = nil
        }

        i += indexBegin < indexEnd ? 1 : -1
    }
    
    
    return (-1, -1)
}

let dataSource: [Double] = [
    1.12,
    2.0,
    2.25,
    3.0,
    2.1,
    4.99,
    1.9,
    1.0,
    4.8
]


func searchContinuityAboveValue(data: [Double], indexBegin: Int, indexEnd: Int, threshold: Double, winLength: Int) -> Int {
    if !validateIndexRange(indexBegin: indexBegin, indexEnd: indexEnd) {
        return -1
    } else if !validateWinLength(winLength: winLength) {
        return -1
    }
    
    return -1
}

func backSearchContinuityWithinRange(data: [Double], indexBegin: Int, indexEnd: Int, thresholdLo: Double, thresholdHi: Double, winLength: Int) -> Int {
    if !validateBackIndexRange(indexBegin: indexBegin, indexEnd: indexEnd) {
        return -1
    } else if !validateThresholdRange(thresholdLo: thresholdLo, thresholdHi: thresholdHi) {
        return -1
    } else if !validateWinLength(winLength: winLength) {
        return -1
    }
    
    return -1
}

func searchContinuityAboveValueTwoSignals(data1: [Double], data2: [Double], indexBegin: Int, indexEnd: Int, threshold1: Double, threshold2: Double, winLength: Int) -> Int {
    if !validateIndexRange(indexBegin: indexBegin, indexEnd: indexEnd) {
        return -1
    } else if !validateWinLength(winLength: winLength) {
        return -1
    }
    
    return -1
}

func searchMultiContinuityWithinRange(data: [Double], indexBegin: Int, indexEnd: Int, thresholdLo: Double, thresholdHi: Double, winLength: Int) -> [(begin: Int, end: Int)] {
    if !validateIndexRange(indexBegin: indexBegin, indexEnd: indexEnd) {
        return [(-1, -1)]
    } else if !validateThresholdRange(thresholdLo: thresholdLo, thresholdHi: thresholdHi) {
        return [(-1, -1)]
    } else if !validateWinLength(winLength: winLength) {
        return [(-1, -1)]
    }
    
    return [(-1, -1)]
}


//MARK: Unit Tests
class ValidationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testWinLengthPositiveValue() {
        XCTAssertEqual(validateWinLength(winLength: 5), true)
    }
    
    func testWinLengthNegativeValue() {
        XCTAssertEqual(validateWinLength(winLength: -5), false)
    }
    
    func testValidateIndexRangeBeginIndexLessThanZero() {
        XCTAssertEqual(validateIndexRange(indexBegin: -5, indexEnd: 5), false)
    }
    
    func testValidateIndexRangeEndIndexLessThanZero() {
        XCTAssertEqual(validateIndexRange(indexBegin: 0, indexEnd: -5), false)
    }
    
    func testValidateIndexRangeEqualIndexes() {
        XCTAssertEqual(validateIndexRange(indexBegin: 0, indexEnd: 0), false)
    }
    
    func testValidateIndexRangeBeginIndexGreaterThanEndIndex() {
        XCTAssertEqual(validateIndexRange(indexBegin: 20, indexEnd: 5), false)
    }
    
    func testValidateIndexRangeCorrect() {
        XCTAssertEqual(validateIndexRange(indexBegin: 0, indexEnd: 500), true)
    }
    
    func testValidateBackIndexRangeBeginIndexLessThanZero() {
        XCTAssertEqual(validateBackIndexRange(indexBegin: -5, indexEnd: 5), false)
    }
    
    func testValidateBackIndexRangeEndIndexLessThanZero() {
        XCTAssertEqual(validateBackIndexRange(indexBegin: 0, indexEnd: -5), false)
    }
    
    func testValidateBackIndexRangeEqualIndexes() {
        XCTAssertEqual(validateBackIndexRange(indexBegin: 5, indexEnd: 5), false)
    }
    
    func testValidateBackIndexRangeBeginIndexLessThanEndIndex() {
        XCTAssertEqual(validateBackIndexRange(indexBegin: 0, indexEnd: 5), false)
    }
    
    func testValidateBackIndexRangeCorrect() {
        XCTAssertEqual(validateBackIndexRange(indexBegin: 500, indexEnd: 0), true)
    }
    
    func testValidateThresholdRangeLoGreaterThanHi() {
        XCTAssertEqual(validateThresholdRange(thresholdLo: 5.5, thresholdHi: 2.5), false)
    }
    
    func testValidateThresholdRangeEqualValues() {
        XCTAssertEqual(validateThresholdRange(thresholdLo: 5.5, thresholdHi: 5.5), false)
    }
    
    func testValidateThresholdRangeCorrect() {
        XCTAssertEqual(validateThresholdRange(thresholdLo: 2.5, thresholdHi: 5.5), true)
    }
    

}

ValidationTests.defaultTestSuite().run()



/*
 
 //MARK: Get data from csv file
 
 var latestSwing: FullSwing?
 
 // Load the data from the provided csv file
 if let url = Bundle.main.url(forResource: "latestSwing", withExtension: "csv") {
 do {
 let fileData = try String(contentsOf: url, encoding: .utf8)
 
 // Separate the file data into an array of values with each index being a line from the file
 let dataComponents = fileData.components(separatedBy: "\r")
 
 var tmpTimestamp: [Int] = []
 var tmpAx: [Double] = []
 var tmpAy: [Double] = []
 var tmpAz: [Double] = []
 var tmpWx: [Double] = []
 var tmpWy: [Double] = []
 var tmpWz: [Double] = []
 
 for data in dataComponents {
 // Separate the line of data into its respective columns
 let columns = data.components(separatedBy: ",")
 
 // The parameters are implicitly unwrapped for this challenge only because we know that all of the values in the csv file are integers or doubles. In normal conditions, we would unwrap them safely using if-let statements
 tmpTimestamp.append(Int(columns[0].replacingOccurrences(of: "\n", with: ""))!)
 tmpAx.append(Double(columns[1])!)
 tmpAy.append(Double(columns[2])!)
 tmpAz.append(Double(columns[3])!)
 tmpWx.append(Double(columns[4])!)
 tmpWy.append(Double(columns[5])!)
 tmpWz.append(Double(columns[6])!)
 }
 
 latestSwing = FullSwing.init(timestamp: tmpTimestamp, ax: tmpAx, ay: tmpAy, az: tmpAz, wx: tmpWx, wy: tmpWy, wz: tmpWz)
 
 } catch {
 print (error)
 }
 
 
 }
 
 //MARK: run our 4 functions against the data found in latestSwing.csv
 
 // safely unwrap our swing data
 if let swing = latestSwing {
 searchContinuityAboveValue(data: swing.ax, indexBegin: 0, indexEnd: swing.ax.count - 1, threshold: 2.0, winLength: 10)
 backSearchContinuityWithinRange(data: swing.wx, indexBegin: swing.wx.count - 1, indexEnd: 0, thresholdLo: -4.0, thresholdHi: 4.0, winLength: 20)
 searchContinuityAboveValueTwoSignals(data1: swing.ay, data2: swing.wy, indexBegin: 0, indexEnd: swing.wx.count - 1, threshold1: 1.2, threshold2: 1.5, winLength: 10)
 searchMultiContinuityWithinRange(data: swing.wy, indexBegin: 0, indexEnd: swing.wy.count - 1, thresholdLo: 1.5, thresholdHi: 8.0, winLength: 10)
 }

 
 
 
 */



