import XCTest
@testable import LyricsService

let testSong = "Uprising"
let testArtist = "Muse"
let duration = 305.0
let searchReq = LyricsSearchRequest(searchTerm: .info(title: testSong, artist: testArtist), duration: duration)

final class LyricsKitTests: XCTestCase {
    
    func _test(provider: LyricsProvider) {
        var searchResultEx: XCTestExpectation? = expectation(description: "Search result: \(provider)")
        let token = provider.lyricsPublisher(request: searchReq).sink { lrc in
            searchResultEx?.fulfill()
            searchResultEx = nil
        }
        waitForExpectations(timeout: 10)
        token.cancel()
    }
    
    func testManager() {
        _test(provider: LyricsProviders.Group())
    }
}
