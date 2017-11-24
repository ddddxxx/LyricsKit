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
    
    public var request: LyricsSearchRequest?
    
    public var lyrics: [Lyrics] = []
    
    public init() {}
    
    fileprivate func searchLyrics(request: LyricsSearchRequest) {
        self.request = request
        lyrics = []
        providers.forEach { $0.cancelSearch() }
        providers.forEach { source in
            dispatchGroup.enter()
            source.searchLyrics(request: request, using: { lrc in
                guard request == self.request else { return }
                
                lrc.metadata.title = request.title
                lrc.metadata.artist = request.artist
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
    
    fileprivate func iFeelLucky(request: LyricsSearchRequest) {
        self.request = request
        lyrics = []
        providers.forEach { $0.cancelSearch() }
        providers.forEach { source in
            dispatchGroup.enter()
            source.iFeelLucky(request: request) {
                defer {
                    self.dispatchGroup.leave()
                }
                if let lrc = $0 {
                    guard self.request == request else { return }
                    
                    lrc.metadata.title = request.title
                    lrc.metadata.artist = request.artist
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
        self.request = nil
        lyrics = []
        providers.forEach { $0.cancelSearch() }
    }
}

