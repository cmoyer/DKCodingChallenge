// ****************************************************
//  DKCodeChallenge.playground
//
//  Created by Chad Moyer on 6/17/17.
// ****************************************************
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

//MARK: Custom Error Handling - In real world application, I would implement these cases so that if one of our 4 functions fails because of improper parameter values, we could
// return a nice to understand error value rather than just returning -1 which makes a developer think that the function didn't find what they were looking for rather than the truth
// that the functions never ran because improper parameter values were used.
enum ParameterValidationError: Error {
    case invalidIndexRange
    case invalidBackIndexRange
    case invalidThresholdRange
    case invalidWinLengthValue
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

func validateContinuous(pointA: Double, pointB: Double) -> Bool {
    // Based on looking through the data, I'm making the assumption that data will be considered 'continuous' 
    // as long as there is not a difference greater than 2.0 between point A and point B
    return !(pointA - pointB > 2 || pointA - pointB < -2)
}

// This function will return the first index where data has values that are above the threshold value for at least winLength samples
func searchContinuityAboveValue(data: [Double], indexBegin: Int, indexEnd: Int, threshold: Double, winLength: Int) -> Int {
    if !validateIndexRange(indexBegin: indexBegin, indexEnd: indexEnd) {
        return -1
    } else if !validateWinLength(winLength: winLength) {
        return -1
    }
    
    var winLengthCounter = 0
    var startIndex = -1
    var prevValue: Double = Double() // We have to initialize the Double because we use in in a closure in the logic below
    
    for index in indexBegin...indexEnd {
        if startIndex == -1 {
            if data[index] > threshold {
                startIndex = index
                winLengthCounter += 1
            }
        } else {
            if data[index] > threshold && validateContinuous(pointA: prevValue, pointB: data[index]) {
                winLengthCounter += 1
            } else {
                winLengthCounter = 0
                startIndex = -1
            }
        }
        
        if winLengthCounter >= winLength {
            return startIndex
        }
        
        prevValue = data[index]
    }
    // If we get to here, we didn't have data continuous for winLength samples, so return -1
    return -1
}

// This function will return the first index where data has values that are within the threshold range for at least winLength samples. 
// In this function, indexBegin will be larger than indexEnd
// NOTE: As I developed this function, I realized I had another question that I should have clarified. In the description of the function in the email from Mike, 
// it says to return the first index where data has values that meet the criteria...etc. Does the first index refer to the first index as we are looping backwards 
// through the array 'data' meaning it will be the last index, or would we want to return the "first" index meaning we should keep going past the winLength 
// value to find the first index as if we were looping through in ascending order? For this coding challeng I have it set up to return the first index in the descending loop.
// If we wanted to switch it to the first index as if we were looping through in ascending order, I would modify the method by removing the winLengthCounter > winLength check, 
// and add conditions to check the counter is greater than winLength when we finally reach an index that either breaks continuity or no longer meets our threshold criteria, then 
// I would return the current Index - 1 as that would be our last valid entry from the array, making it the 'first' index in the array.
func backSearchContinuityWithinRange(data: [Double], indexBegin: Int, indexEnd: Int, thresholdLo: Double, thresholdHi: Double, winLength: Int) -> Int {
    if !validateBackIndexRange(indexBegin: indexBegin, indexEnd: indexEnd) {
        return -1
    } else if !validateThresholdRange(thresholdLo: thresholdLo, thresholdHi: thresholdHi) {
        return -1
    } else if !validateWinLength(winLength: winLength) {
        return -1
    }
    
    var winLengthCounter = 0
    var startIndex = -1
    var prevValue: Double = Double()
    
    for index in (indexEnd...indexBegin).reversed() {
        if startIndex == -1 {
            if data[index] > thresholdLo && data[index] < thresholdHi {
                startIndex = index
                winLengthCounter += 1
            }
        } else {
            if data[index] > thresholdLo && data[index] < thresholdHi && validateContinuous(pointA: prevValue, pointB: data[index]) {
                winLengthCounter += 1
            } else {
                winLengthCounter = 0
                startIndex = -1
            }
        }
        
        if winLengthCounter >= winLength {
            return startIndex
        }
        
        prevValue = data[index]
    }
    
    return -1
}

// This function will return the first index where both data1 and data2 have values that are above threshold1 and threshold2 respectively, for at least winLength samples.
func searchContinuityAboveValueTwoSignals(data1: [Double], data2: [Double], indexBegin: Int, indexEnd: Int, threshold1: Double, threshold2: Double, winLength: Int) -> Int {
    if !validateIndexRange(indexBegin: indexBegin, indexEnd: indexEnd) {
        return -1
    } else if !validateWinLength(winLength: winLength) {
        return -1
    }
    
    var winLengthCounter = 0
    var startIndex = -1
    var prevValue1: Double = Double()
    var prevValue2: Double = Double()
    
    for index in indexBegin...indexEnd {
        if startIndex == -1 {
            if data1[index] > threshold1 && data2[index] > threshold2 {
                startIndex = index
                winLengthCounter += 1
            }
        } else {
            if (data1[index] > threshold1 && validateContinuous(pointA: prevValue1, pointB: data1[index])) && (data2[index] > threshold2 && validateContinuous(pointA: prevValue2, pointB: data2[index])) {
                winLengthCounter += 1
            } else {
                winLengthCounter = 0
                startIndex = -1
            }
        }
        
        if winLengthCounter >= winLength {
            return startIndex
        }
        
        prevValue1 = data1[index]
        prevValue2 = data2[index]
    }
    
    return -1
}

// This function will return the startIndex and endIndex for ALL continuous samples where data is within the threshold range for at least winLength samples
func searchMultiContinuityWithinRange(data: [Double], indexBegin: Int, indexEnd: Int, thresholdLo: Double, thresholdHi: Double, winLength: Int) -> [(begin: Int, end: Int)] {
    var multiContRanges: [(Int, Int)] = []
    var winLengthCounter = 0
    var startIndex = -1
    var endIndex = -1
    var prevValue: Double = Double()
    
    for index in indexBegin...indexEnd {
        if startIndex == -1 {
            if data[index] > thresholdLo && data[index] < thresholdHi {
                startIndex = index
                winLengthCounter += 1
            }
        } else {
            if data[index] > thresholdLo && data[index] < thresholdHi && validateContinuous(pointA: prevValue, pointB: data[index]) {
                winLengthCounter += 1
            } else {
                if winLengthCounter > winLength {
                    endIndex = index - 1
                    multiContRanges.append((startIndex, endIndex))
                }
                winLengthCounter = 0
                startIndex = -1
                endIndex = -1
            }
        }
        
        prevValue = data[index]
    }
    
    // We need to do one final check to catch the case where we had a startIndex towards the end of the loop, but reached the endIndex before we pushed it to the array
    // If that is the case, pushe the data to the array and then return the array of tuples, otherwise check to see if anything is in the array and make the necessary return
    if startIndex > -1 && winLengthCounter > winLength {
        endIndex = indexEnd
        multiContRanges.append((startIndex, endIndex))
        return multiContRanges
    } else {
        if multiContRanges.count > 0 {
            return multiContRanges
        } else {
            return [(-1, -1)]
        }
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
    
    func testValidateContinuousFailPositive() {
        XCTAssertEqual(validateContinuous(pointA: 12.5, pointB: 3.9), false)
    }
    
    func testValidateContinuousPassPositive() {
        XCTAssertEqual(validateContinuous(pointA: 12.5, pointB: 11.752), true)
    }
    
    func testValidateContinuousFailNegative(){
        XCTAssertEqual(validateContinuous(pointA: -15.567, pointB: -2.36), false)
        XCTAssertEqual(validateContinuous(pointA: 2.2, pointB: 15.658), false)
        XCTAssertEqual(validateContinuous(pointA: 15.658, pointB: 31.22), false)
    }
    
    func testValidateContinuousPassNegative() {
        XCTAssertEqual(validateContinuous(pointA: -12.378, pointB: -11.72), true)
    }
}

ValidationTests.defaultTestSuite().run()

class MainFunctionTests: XCTestCase {
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
        XCTAssertEqual(searchContinuityAboveValue(data: testData1, indexBegin: 0, indexEnd: testData1.count - 1, threshold: 1.2, winLength: 25), -1)
        XCTAssertEqual(searchContinuityAboveValue(data: testData2, indexBegin: 0, indexEnd: testData2.count - 1, threshold: 1.2, winLength: 10), 11)
    }
    
    func testBackSearchContinuityWithinRange() {
        XCTAssertEqual(backSearchContinuityWithinRange(data: testData1, indexBegin: testData1.count - 1, indexEnd: 0, thresholdLo: 1.0, thresholdHi: 2.0, winLength: 5), -1)
        XCTAssertEqual(backSearchContinuityWithinRange(data: testData2, indexBegin: testData2.count - 1, indexEnd: 0, thresholdLo: 1.0, thresholdHi: 2.0, winLength: 5), 17)
    }
    
    func testSearchContinuityAboveValueTwoSignals() {
        XCTAssertEqual(searchContinuityAboveValueTwoSignals(data1: testData1, data2: testData2, indexBegin: 0, indexEnd: testData1.count - 1, threshold1: 3.0, threshold2: 1.3, winLength: 5), 12)
        XCTAssertEqual(searchContinuityAboveValueTwoSignals(data1: testData1, data2: testData2, indexBegin: 0, indexEnd: testData1.count - 1, threshold1: 3.0, threshold2: 1.2, winLength: 15), -1)
        XCTAssertEqual(searchContinuityAboveValueTwoSignals(data1: testData1, data2: testData2, indexBegin: 0, indexEnd: testData1.count - 1, threshold1: 3.0, threshold2: 1.2, winLength: 14), 11)
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

        // For this test, by increasing our winLength to 5, we should exclude the first tuple of values (0,4)
        let testValue2 = searchMultiContinuityWithinRange(data: testData2, indexBegin: 0, indexEnd: testData2.count - 1, thresholdLo: 0.0, thresholdHi: 4.0, winLength: 5)
        let test2Tuple = testValue2[0]
        let begin = test2Tuple.begin
        let end = test2Tuple.end
        
        XCTAssertTrue(begin == 7)
        XCTAssertTrue(end == 28)

        
    }
}

MainFunctionTests.defaultTestSuite().run()



//MARK: Get data from csv file

//var fullSwing: [SwingSample] = []
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
    searchContinuityAboveValueTwoSignals(data1: swing.wx, data2: swing.wy, indexBegin: 0, indexEnd: swing.wx.count - 1, threshold1: 2.0, threshold2: 2.5, winLength: 10)
    searchMultiContinuityWithinRange(data: swing.az, indexBegin: 0, indexEnd: 0, thresholdLo: 1.5, thresholdHi: 8.0, winLength: 10)
}

