import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        let arrayNums = [1, 3, 4, 2, 8]
        
        let value = arrayNums[safe: 2]
        
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 4)
    }
    
    func testGetValueOutOfRange() throws {
        let array = [1, 1, 2, 3, 5]
        
        let value = array[safe: 20]
        
        XCTAssertNil(value)
    }
}
