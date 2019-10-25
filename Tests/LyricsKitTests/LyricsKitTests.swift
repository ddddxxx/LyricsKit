import XCTest
@testable import LyricsService

let testSong = "Uprising"
let testArtist = "Muse"
let duration = 305.0
let searchReq = LyricsSearchRequest(searchTerm: .info(title: testSong, artist: testArtist), title: testSong, artist: testArtist, duration: duration)

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

    func testNetEase() {
        _test(provider: LyricsProviders.NetEase())
    }

    func testQQ() {
        _test(provider: LyricsProviders.QQMusic())
    }

    func testKugou() {
        _test(provider: LyricsProviders.Kugou())
    }

    func testXiami() {
        _test(provider: LyricsProviders.Xiami())
    }

    func testGecimi() {
        _test(provider: LyricsProviders.Gecimi())
    }

    func testViewLyrics() {
        _test(provider: LyricsProviders.ViewLyrics())
    }

    func testSyair() {
        _test(provider: LyricsProviders.Syair())
    }

    static var allTests = [
        ("testNetEase", testNetEase),
    ]
}
