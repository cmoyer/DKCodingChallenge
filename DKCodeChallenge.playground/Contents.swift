// ****************************************************
//  DKCodeChallenge.playground
//
//  Created by Chad Moyer on 6/17/17.
// ****************************************************
import UIKit
import XCTest


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
    
    for index in indexBegin...indexEnd {
        if data[index] > threshold {
            if startIndex == -1 {
                startIndex = index
            }
            winLengthCounter += 1
        } else {
            // this value isn't above the threshold, reset our tmp counter & starting index
            winLengthCounter = 0
            startIndex = -1
        }
        
        if winLengthCounter >= winLength {
            return startIndex
        }
    }
    // If we get to here, we didn't have data continuous for winLength samples, so return -1
    return -1
}

// This function will return the first index where data has values that are within the threshold range for at least winLength samples. 
// In this function, indexBegin will be larger than indexEnd
func backSearchContinuityWithinRange(data: [Double], indexBegin: Int, indexEnd: Int, thresholdLo: Double, thresholdHi: Double, winLength: Int) -> Int {
    if !validateBackIndexRange(indexBegin: indexBegin, indexEnd: indexEnd) {
        return -1
    } else if !validateThresholdRange(thresholdLo: thresholdLo, thresholdHi: thresholdHi) {
        return -1
    } else if !validateWinLength(winLength: winLength) {
        return -1
    }
    
    
    return 0
}

// This function will return the first index where both data1 and data2 have values that are above threshold1 and threshold2 respectively, for at least winLength samples.
func searchContinuityAboveValueTwoSignals(data1: [Double], data2: [Double], indexBegin: Int, indexEnd: Int, threshold1: Double, threshold2: Double, winLength: Int) -> Int {
    if !validateIndexRange(indexBegin: indexBegin, indexEnd: indexEnd) {
        return -1
    } else if !validateWinLength(winLength: winLength) {
        return -1
    }
    
    return 0
}

// This function will return the startIndex and endIndex for ALL continuous samples where data is within the threshold range for at least winLength samples
func searchMultiContinuityWithinRange(data: [Double], indexBegin: Int, indexEnd: Int, thresholdLo: Double, thresholdHi: Double, winLength: Int) -> [(begin: Int, end: Int)] {
    var multiContRanges: [Int] = []
    
    return [(0, 0)]
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
    }
    
    func testValidateContinuousPassNegative() {
        XCTAssertEqual(validateContinuous(pointA: -12.378, pointB: -11.72), true)
    }
}

ValidationTests.defaultTestSuite().run()

class MainFunctionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
}

/*

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

*/
