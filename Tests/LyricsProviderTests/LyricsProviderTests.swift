import XCTest
@testable import LyricsProvider

class LyricsProviderTests: XCTestCase {
    
    let testSong = "Uprising"
    let testArtist = "Muse"
    
    func testSearchLyricsPerformance() {
        let src = LyricsProviderManager()
        
        measure {
            let searchCompleteEx = self.expectation(description: "Search complete")
            let consumer = TestConsumer(completedHandle: {
                searchCompleteEx.fulfill()
            })
            src.consumer = consumer
            src.searchLyrics(title: self.testSong, artist: self.testArtist, duration: 230)
            self.waitForExpectations(timeout: 10)
        }
    }
    
    func testIfeelLucky() {
        let lyricsProviders: [LyricsProvider] = [
            LyricsXiami(),
            LyricsGecimi(),
            LyricsTTPod(),
            Lyrics163(),
            LyricsQQ(),
            ]
        lyricsProviders.forEach { provider in
            let searchCompleteEx = expectation(description: "Search complete: \(provider)")
            provider.iFeelLucky(term: .info(title: testSong, artist: testArtist), duration: 0) {
                if $0 != nil {
                    searchCompleteEx.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 10)
    }
    
    func testLyricsProviderAvailability() {
        let lyricsProviders: [LyricsProvider] = [
            LyricsXiami(),
            LyricsGecimi(),
            LyricsTTPod(),
            Lyrics163(),
            LyricsQQ(),
            ]
        lyricsProviders.forEach { provider in
            var searchResultEx: XCTestExpectation? = expectation(description: "Search result: \(provider)")
            let searchCompleteEx = expectation(description: "Search complete: \(provider)")
            provider.searchLyrics(term: .info(title: testSong, artist: testArtist), duration: 0, using: {_ in
                searchResultEx?.fulfill()
                searchResultEx = nil
            }, completionHandler: {
                searchCompleteEx.fulfill()
            })
        }
        waitForExpectations(timeout: 10)
    }


    static var allTests = [
        ("testFetchLyricsPerformance", testSearchLyricsPerformance),
        ("testLyricsSourceAvailability", testLyricsProviderAvailability),
    ]
}

class TestConsumer: LyricsConsuming {
    
    private let receivedHandle: (() -> Void)?
    private let completedHandle: (() -> Void)?
    
    init(receivedHandle: (() -> Void)? = nil, completedHandle: (() -> Void)? = nil) {
        self.receivedHandle = receivedHandle
        self.completedHandle = completedHandle
    }
    
    func lyricsReceived(lyrics: Lyrics) {
        receivedHandle?()
    }
    
    func fetchCompleted(result: [Lyrics]) {
        completedHandle?()
    }
    
}
