//
//  ProviderTests.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017  Xander Deng
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
@testable import LyricsProvider

class ProviderTests: XCTestCase {
    
    let testSong = "Uprising"
    let testArtist = "Muse"
    let duration = 305.0
    
    func _test(provider: LyricsProvider) {
        var searchResultEx: XCTestExpectation? = expectation(description: "Search result: \(provider)")
        let searchCompleteEx = expectation(description: "Search complete: \(provider)")
        provider.searchLyrics(term: .info(title: testSong, artist: testArtist), duration: duration, using: { _ in
            searchResultEx?.fulfill()
            searchResultEx = nil
        }, completionHandler: {
            searchCompleteEx.fulfill()
        })
        waitForExpectations(timeout: 10)
    }
    
    func testNetEase() {
        _test(provider: Lyrics163())
    }
    
    func testQQ() {
        _test(provider: LyricsQQ())
    }
    
    func testKugou() {
        _test(provider: LyricsKugou())
    }
    
    func testXiami() {
        _test(provider: LyricsXiami())
    }
    
    func testTTPod() {
        _test(provider: LyricsTTPod())
    }
    
    func testGecimi() {
        _test(provider: LyricsGecimi())
    }
    
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
