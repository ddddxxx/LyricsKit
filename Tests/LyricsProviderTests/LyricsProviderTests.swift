import XCTest
@testable import LyricsProvider

class LyricsProviderTests: XCTestCase {
    
    func testFetchLyricsPerformance() {
        let testSong = "Rolling in the Deep"
        let testArtist = "Adele"
        let src = LyricsProviderManager()
        
        measure {
            var fetchReturnedEx: XCTestExpectation? = self.expectation(description: "fetch lrc")
            let fetchCompleteEx = self.expectation(description: "fetch complete")
            let consumer = TestConsumer(completedHandle: {
                fetchReturnedEx?.fulfill()
                fetchReturnedEx = nil
                fetchCompleteEx.fulfill()
            })
            src.consumer = consumer
            src.searchLyrics(title: testSong, artist: testArtist, duration: 230)
            self.waitForExpectations(timeout: 10) { _ in
                self.stopMeasuring()
            }
        }
    }
    
    func testLyricsSourceAvailability() {
        let testCase = [
            ("Rolling in the Deep", "Adele"),
//            ("海阔天空", "Beyond"),
            ]
        
        let lyricsSources: [LyricsProvider] = [
//            LyricsXiami(),
//            LyricsGecimi(),
//            LyricsTTPod(),
//            Lyrics163(),
            LyricsQQ(),
            ]
        lyricsSources.forEach { src in
            var fetchReturnedEx: XCTestExpectation? = expectation(description: "fetch from \(src)")
            let fetchCompleteEx = expectation(description: "fetch complete \(src)")
            for song in testCase {
                src.searchLyrics(criteria: .info(title: song.0, artist: song.1), duration: 0, using: {_ in
                    fetchReturnedEx?.fulfill()
                    fetchReturnedEx = nil
                }, completionHandler: {
                    fetchCompleteEx.fulfill()
                })
            }
            waitForExpectations(timeout: 10)
        }
    }


    static var allTests = [
        ("testFetchLyricsPerformance", testFetchLyricsPerformance),
        ("testLyricsSourceAvailability", testLyricsSourceAvailability),
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
