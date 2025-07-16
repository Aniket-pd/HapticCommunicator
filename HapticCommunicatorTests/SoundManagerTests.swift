import XCTest
@testable import HapticCommunicator

final class SoundManagerTests: XCTestCase {
    func testPlayersLoaded() {
        let manager = SoundManager.shared
        XCTAssertNotNil(manager.dotPlayer, "Dot player should be loaded")
        XCTAssertNotNil(manager.dashPlayer, "Dash player should be loaded")
    }
}
