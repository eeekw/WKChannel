import XCTest
@testable import WKChannel

final class WKChannelTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(WKChannelConnect().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
