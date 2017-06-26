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
func withinThreshold(value: Double, threshold: (lo: Double, hi: Double?), value2: Double?, threshold2: Double?) -> Bool {
    var predicate: NSPredicate
    
    if let val2 = value2, let thresh2 = threshold2 {
        predicate = NSPredicate(format: "\(value) > \(threshold.lo) && \(val2) > \(thresh2)")
    } else {
        if let thresholdHi = threshold.hi {
            predicate = NSPredicate(format: "SELF BETWEEN {\(threshold.lo), \(thresholdHi)}")
        } else {
            predicate = NSPredicate(format: "SELF > \(threshold.lo)")
        }
    }
    
    return predicate.evaluate(with: value)
}

//withinThreshold(value: 3.5, threshold: (4.0, nil))

func searchContinuity(data: [Double], data2: [Double]?, indexBegin: Int, indexEnd: Int, threshold: (lo: Double, hi: Double?), threshold2: Double?, winLength: Int) -> (begin: Int, end: Int) {
    
    var winLengthCounter = 0
    var startIndex: Int?
    var value2: Double?
    var threshold2Value: Double?
    var i = indexBegin
    
    while i != indexEnd {
        // If the value is still within the threshold, increment the counter and set the startIndex if it is nil.
        // Otherwise, we have reached a value that is not within the threshold so check to see if we have reached the winLength window.
        // If we have, return the start, end pair. If we haven't reset our counter and startIndex back to 0 and nil respectively.
        if let hasData2 = data2, let hasThreshold2 = threshold2 {
            value2 = hasData2[i]
            threshold2Value = hasThreshold2
        } else {
            value2 = nil
            threshold2Value = nil
        }
        switch withinThreshold(value: data[i], threshold: threshold, value2: value2, threshold2: threshold2Value) {
        case true:
            winLengthCounter += 1
            if startIndex == nil {
                startIndex = i
            }
        case false:
            if winLengthCounter >= winLength {
                return (startIndex!, i) // we can force-unwrap the startIndex because it will have to have a value if counter > winLength
            } else {
                winLengthCounter = 0
                startIndex = nil
            }
        }

        i += indexBegin < indexEnd ? 1 : -1 // This ternary operation lets us dynamically increment/decrement the while loop variable based on which index value is larger.
    }
    
    if winLengthCounter > winLength {
        return (startIndex!, i)
    } else {
        return (-1, -1)
    }
}


func searchContinuityAboveValue(data: [Double], indexBegin: Int, indexEnd: Int, threshold: Double, winLength: Int) -> Int {
    if !validateIndexRange(indexBegin: indexBegin, indexEnd: indexEnd) {
        return -1
    } else if !validateWinLength(winLength: winLength) {
        return -1
    }
    
    let index = searchContinuity(data: data, data2: nil, indexBegin: indexBegin, indexEnd: indexEnd, threshold: (threshold, nil), threshold2: nil, winLength: winLength)
    return index.begin
}

func backSearchContinuityWithinRange(data: [Double], indexBegin: Int, indexEnd: Int, thresholdLo: Double, thresholdHi: Double, winLength: Int) -> Int {
    if !validateBackIndexRange(indexBegin: indexBegin, indexEnd: indexEnd) {
        return -1
    } else if !validateThresholdRange(thresholdLo: thresholdLo, thresholdHi: thresholdHi) {
        return -1
    } else if !validateWinLength(winLength: winLength) {
        return -1
    }
    
    let index = searchContinuity(data: data, data2: nil, indexBegin: indexBegin, indexEnd: indexEnd, threshold: (thresholdLo, thresholdHi), threshold2: nil, winLength: winLength)
    if index.end == -1 {
        return -1
    } else {
        // In this case, because we are searching backwards, the index.end will be the starting point. Because the function is setup so that the 'end' point is where we should
        // start looping through again in the multiContinuity, we need to add 1 to the value we find here so it correctly reflects the proper startIndex.
        return index.end + 1
    }
    
}

func searchContinuityAboveValueTwoSignals(data1: [Double], data2: [Double], indexBegin: Int, indexEnd: Int, threshold1: Double, threshold2: Double, winLength: Int) -> Int {
    if !validateIndexRange(indexBegin: indexBegin, indexEnd: indexEnd) {
        return -1
    } else if !validateWinLength(winLength: winLength) {
        return -1
    }
    
    let index = searchContinuity(data: data1, data2: data2, indexBegin: indexBegin, indexEnd: indexEnd, threshold: (threshold1, nil), threshold2: threshold2, winLength: winLength)
    return index.begin
}

func searchMultiContinuityWithinRange(data: [Double], indexBegin: Int, indexEnd: Int, thresholdLo: Double, thresholdHi: Double, winLength: Int) -> [(begin: Int, end: Int)] {
    if !validateIndexRange(indexBegin: indexBegin, indexEnd: indexEnd) {
        return [(-1, -1)]
    } else if !validateThresholdRange(thresholdLo: thresholdLo, thresholdHi: thresholdHi) {
        return [(-1, -1)]
    } else if !validateWinLength(winLength: winLength) {
        return [(-1, -1)]
    }
    
    var multiContRanges: [(Int, Int)] = []
    var index = 0
    while index < indexEnd {
        var dataPoint = searchContinuity(data: data, data2: nil, indexBegin: index, indexEnd: indexEnd, threshold: (thresholdLo, thresholdHi), threshold2: nil, winLength: winLength)
        index = dataPoint.end
        if dataPoint.end < data.count - 1 {
            // If this point doesn't have an end point that is the last value in our array, we need to subtract one from the .end value to get the true 'indexEnd'
            dataPoint.end = dataPoint.end - 1
        }
        multiContRanges.append(dataPoint)
    }
    
    if multiContRanges.count > 0 {
        return multiContRanges
    } else {
        return [(-1, -1)]
    }
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

class MainFunctionAndHelperTests: XCTestCase {
    var testData1: [Double] = []
    var testData2: [Double] = []
    override func setUp() {
        super.setUp()
        testData1 = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 26.0, 35.0, 42.0, 113.0, -5.0] //29 so last is 28
        testData2 = [1.0, 1.5, 1.02, 1.6845213, 2.2, 15.658, 31.22, 1.568, 1.0, 1.1, 1.2, 1.3, 1.4, 1.45, 1.6, 1.89, 1.95, 1.25, 2.24, 2.3, 2.8, 1.5, 2.2, 2.5, 2.5, 2.6524, 1.5, 1.2, 1.0]
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSearchContinuityAboveValue() {
        XCTAssertEqual(searchContinuityAboveValue(data: testData1, indexBegin: 0, indexEnd: testData1.count - 1, threshold: 1.2, winLength: 5), 1)
        XCTAssertEqual(searchContinuityAboveValue(data: testData1, indexBegin: 0, indexEnd: testData1.count - 1, threshold: 1.2, winLength: 29), -1)
        XCTAssertEqual(searchContinuityAboveValue(data: testData2, indexBegin: 0, indexEnd: testData2.count - 1, threshold: 1.2, winLength: 10), 11)

    }
    
    func testBackSearchContinuityWithinRange() {
        XCTAssertEqual(backSearchContinuityWithinRange(data: testData1, indexBegin: testData1.count - 1, indexEnd: 0, thresholdLo: 1.0, thresholdHi: 2.0, winLength: 5), -1)
        XCTAssertEqual(backSearchContinuityWithinRange(data: testData2, indexBegin: testData2.count - 1, indexEnd: 0, thresholdLo: 1.0, thresholdHi: 2.0, winLength: 5), 7)
    }
    
    func testSearchCOntinuityAboveValueTwoSignals() {
        XCTAssertEqual(searchContinuityAboveValueTwoSignals(data1: testData1, data2: testData2, indexBegin: 0, indexEnd: testData1.count - 1, threshold1: 3.0, threshold2: 1.3, winLength: 5), 3)
        XCTAssertEqual(searchContinuityAboveValueTwoSignals(data1: testData1, data2: testData2, indexBegin: 0, indexEnd: testData1.count - 1, threshold1: 3.0, threshold2: 1.2, winLength: 15), 11)
        XCTAssertEqual(searchContinuityAboveValueTwoSignals(data1: testData1, data2: testData2, indexBegin: 0, indexEnd: testData1.count - 1, threshold1: 3.0, threshold2: 1.2, winLength: 14), 11)
        XCTAssertEqual(searchContinuityAboveValueTwoSignals(data1: testData1, data2: testData2, indexBegin: 0, indexEnd: testData1.count - 1, threshold1: 10.0, threshold2: 2.0, winLength: 5), -1)

    }
    
    func testSearchMultiContinuityWithinRange() {
        // I ran into some unexpected issues when attempting to use the XCTAssertEquals or XCTAssertTrue with our last function that returns an array of tuples.
        // Therefore, I had to do some roundabout setup to get our test cases going.
        let testValue1 = searchMultiContinuityWithinRange(data: testData2, indexBegin: 0, indexEnd: testData2.count - 1, thresholdLo: 0.0, thresholdHi: 4.0, winLength: 4)
        let firstTuple = testValue1[0]
        let firstBegin = firstTuple.begin
        let firstEnd = firstTuple.end
        
        let secondTuple = testValue1[1]
        let secondBegin = secondTuple.begin
        let secondEnd = secondTuple.end
        
        XCTAssertTrue(firstBegin == 0)
        XCTAssertTrue(firstEnd == 4)
        XCTAssertTrue(secondBegin == 7)
        XCTAssertTrue(secondEnd == 28)
        
        // For this test, by increasing our thresholdHi to 40.0, the entire array should be considered continuous.
        let testValue2 = searchMultiContinuityWithinRange(data: testData2, indexBegin: 0, indexEnd: testData2.count - 1, thresholdLo: 0.0, thresholdHi: 40.0, winLength: 5)
        let test2Tuple = testValue2[0]
        let begin = test2Tuple.begin
        let end = test2Tuple.end
        
        XCTAssertTrue(begin == 0)
        XCTAssertTrue(end == 28)

    }
}

ValidationTests.defaultTestSuite().run()
MainFunctionAndHelperTests.defaultTestSuite().run()



 
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

 
 
 




