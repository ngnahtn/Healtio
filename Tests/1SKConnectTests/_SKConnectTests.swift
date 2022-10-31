import XCTest
@testable import _SKConnect

final class _SKConnectTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(_SKConnect().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
