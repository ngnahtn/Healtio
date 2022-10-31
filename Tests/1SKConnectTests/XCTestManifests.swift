import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(_SKConnectTests.allTests),
    ]
}
#endif
