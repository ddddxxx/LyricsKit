//
//  LyricsProviderManager.swift
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

import Foundation

public protocol LyricsConsuming: class {
    
    func lyricsReceived(lyrics: Lyrics)
    
    func fetchCompleted(result: [Lyrics])
}

public class LyricsProviderManager {
    
    public weak var consumer: LyricsConsuming?
    
    private var dispatchGroup = DispatchGroup()
    let providers: [LyricsProvider] = [
        LyricsXiami(),
        LyricsGecimi(),
        LyricsNetEase(),
        LyricsQQ(),
        LyricsKugou(),
    ]
    
    public var term: Lyrics.MetaData.SearchTerm?
    
    public var lyrics: [Lyrics] = []
    
    public init() {}
    
    fileprivate func searchLyrics(term: Lyrics.MetaData.SearchTerm, title: String?, artist: String?, duration: TimeInterval) {
        self.term = term
        lyrics = []
        providers.forEach { $0.cancelSearch() }
        providers.forEach { source in
            dispatchGroup.enter()
            source.searchLyrics(term: term, duration: duration, using: { lrc in
                guard self.term == term else {
                    return
                }
                
                lrc.metadata.title = title
                lrc.metadata.artist = artist
                lrc.idTags[.recreater] = "LyricsX"
                lrc.idTags[.version] = "1"
                
                let index = self.lyrics.index(where: {$0 < lrc}) ?? self.lyrics.count
                self.lyrics.insert(lrc, at: index)
                self.consumer?.lyricsReceived(lyrics: lrc)
            }, completionHandler: {
                self.dispatchGroup.leave()
            })
        }
        dispatchGroup.notify(queue: .global()) {
            self.consumer?.fetchCompleted(result: self.lyrics)
        }
    }
    
    fileprivate func iFeelLucky(term: Lyrics.MetaData.SearchTerm, title: String?, artist: String?, duration: TimeInterval) {
        self.term = term
        lyrics = []
        providers.forEach { $0.cancelSearch() }
        providers.forEach { source in
            dispatchGroup.enter()
            source.iFeelLucky(term: term, duration: duration) {
                defer {
                    self.dispatchGroup.leave()
                }
                if let lrc = $0 {
                    guard self.term == term else {
                        return
                    }
                    lrc.metadata.title = title
                    lrc.metadata.artist = artist
                    lrc.idTags[.recreater] = "LyricsX"
                    lrc.idTags[.version] = "1"
                    
                    let index = self.lyrics.index(where: {$0 < lrc}) ?? self.lyrics.count
                    self.lyrics.insert(lrc, at: index)
                    self.consumer?.lyricsReceived(lyrics: lrc)
                }
            }
        }
        dispatchGroup.notify(queue: .global()) {
            self.consumer?.fetchCompleted(result: self.lyrics)
        }
    }
    
    public func cancelSearching() {
        self.term = nil
        lyrics = []
        providers.forEach { $0.cancelSearch() }
    }
}

extension LyricsProviderManager {
    
    public func searchLyrics(searchTitle: String? = nil, searchArtist: String? = nil, title: String, artist: String, duration: TimeInterval) {
        let term = Lyrics.MetaData.SearchTerm.info(title: searchTitle ?? title, artist: searchTitle ?? title)
        searchLyrics(term: term, title: title, artist: artist, duration: duration)
    }
    
    public func iFeelLucky(searchTitle: String? = nil, searchArtist: String? = nil, title: String, artist: String, duration: TimeInterval) {
        let term = Lyrics.MetaData.SearchTerm.info(title: searchTitle ?? title, artist: searchTitle ?? title)
        iFeelLucky(term: term, title: title, artist: artist, duration: duration)
    }
    
    public func searchLyrics(keyword: String, title: String, artist: String, duration: TimeInterval) {
        searchLyrics(term: .keyword(keyword), title: title, artist: artist, duration: duration)
    }
    
    public func iFeelLucky(keyword: String, title: String, artist: String, duration: TimeInterval) {
        iFeelLucky(term: .keyword(keyword), title: title, artist: artist, duration: duration)
    }
    
}

