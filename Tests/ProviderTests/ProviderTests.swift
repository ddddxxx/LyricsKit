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

let testSong = "Uprising"
let testArtist = "Muse"
let duration = 305.0
let searchReq = LyricsSearchRequest(searchTerm: .info(title: testSong, artist: testArtist), title: testSong, artist: testArtist, duration: duration)

class ProviderTests: XCTestCase {
    
    func _test(provider: LyricsProvider) {
        var searchResultEx: XCTestExpectation? = expectation(description: "Search result: \(provider)")
        let searchCompleteEx = expectation(description: "Search complete: \(provider)")
        let task = provider.lyricsTask(request: searchReq) { lrc in
            searchResultEx?.fulfill()
            searchResultEx = nil
        }
        let token = task.progress.observe(\.isFinished, options: [.new]) { progress, change in
            if change.newValue == true {
                searchCompleteEx.fulfill()
            }
        }
        task.resume()
        waitForExpectations(timeout: 10)
    }
    
    func testNetEase() {
        _test(provider: LyricsNetEase(session: .shared))
    }
    
    func testQQ() {
        _test(provider: LyricsQQ(session: .shared))
    }
    
    func testKugou() {
        _test(provider: LyricsKugou(session: .shared))
    }
    
    func testXiami() {
        _test(provider: LyricsXiami(session: .shared))
    }
    
    func testGecimi() {
        _test(provider: LyricsGecimi(session: .shared))
    }
    
    func testViewLyrics() {
        _test(provider: ViewLyrics(session: .shared))
    }
    
    func testSyair() {
        _test(provider: LyricsSyair(session: .shared))
    }
    
    func testSearchLyricsPerformance() {
        let src = LyricsProviderManager()
        measure {
            let searchCompleteEx = self.expectation(description: "Search complete")
            let task = src.searchLyrics(request: searchReq) { _ in }
            _ = task.progress.observe(\.isFinished, options: [.new]) { progress, change in
                if change.newValue == true {
                    searchCompleteEx.fulfill()
                }
            }
            self.waitForExpectations(timeout: 10)
        }
    }
}
