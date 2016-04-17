import XCTest
@testable import NestS4

class NestS4: XCTestCase {

	func testExample() {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
	}

}

#if os(Linux)
extension NestS4: XCTestCaseProvider {
	var allTests : [(String, () throws -> Void)] {
		return [
			("testExample", testExample),
		]
	}
}
#endif
