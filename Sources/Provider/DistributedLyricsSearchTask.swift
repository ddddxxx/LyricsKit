//
//  DistributedLyricsSearchTask.swift
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

struct _AnyLyricsProvider {
    
    private var _searchTask: (LyricsSearchRequest, @escaping ([Any]) -> Void) -> Void
    private var _fetchTask: (Any, @escaping (Lyrics?) -> Void) -> Void
    
    init<T: _LyricsProvider>(_ provider: T) {
        _searchTask = { req, callback in
            provider.searchTask(request: req, completionHandler: { tokens in
                callback(tokens)
            })
        }
        _fetchTask = { token, callback in
            provider.fetchTask(token: token as! T.LyricsToken, completionHandler: callback)
        }
    }
    
    func searchTask(request: LyricsSearchRequest, completionHandler: @escaping ([Any]) -> Void) {
        _searchTask(request, completionHandler)
    }
    
    func fetchTask(token: Any, completionHandler: @escaping (Lyrics?) -> Void) {
        _fetchTask(token, completionHandler)
    }
}

public class DistributedLyricsSearchTask {
    
    public let request: LyricsSearchRequest
    public var progress: Progress
    
    var provider: _AnyLyricsProvider
    var handler: (Lyrics) -> Void
    
    init(request: LyricsSearchRequest, provider: _AnyLyricsProvider, handler: @escaping (Lyrics) -> Void) {
        self.request = request
        self.provider = provider
        self.handler = handler
        progress = Progress(parent: Progress.current())
        progress.totalUnitCount = 10
    }
    
    func resume() {
        progress.becomeCurrent(withPendingUnitCount: 2)
        provider.searchTask(request: request, completionHandler: self.searchComplete)
        progress.resignCurrent()
    }
    
    private func searchComplete(tokens: [Any]) {
        progress.becomeCurrent(withPendingUnitCount: 8)
        defer { progress.resignCurrent() }
        guard !tokens.isEmpty else { return }
        let fetchProgress = Progress(parent: Progress.current())
        fetchProgress.totalUnitCount = Int64(tokens.count)
        tokens.enumerated().forEach { (idx, token) in
            fetchProgress.becomeCurrent(withPendingUnitCount: 1)
            defer { fetchProgress.resignCurrent() }
            provider.fetchTask(token: token) { lrc in
                lrc?.metadata.searchIndex = idx
                self.fetchComplete(lyrics: lrc)
            }
        }
    }
    
    private func fetchComplete(lyrics: Lyrics?) {
        if let lyrics = lyrics {
            lyrics.metadata.request = request
            handler(lyrics)
        }
    }
}
