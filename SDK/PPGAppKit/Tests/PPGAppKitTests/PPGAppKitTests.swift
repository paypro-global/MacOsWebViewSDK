import XCTest
@testable import PPGAppKit

final class PPGAppKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(PPGAppKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
