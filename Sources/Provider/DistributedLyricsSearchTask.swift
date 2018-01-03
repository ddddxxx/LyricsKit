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
    
    private var _searchTask: (LyricsSearchRequest, @escaping ([Any]) -> Void) -> URLSessionTask?
    private var _fetchTask: (Any, @escaping (Lyrics?) -> Void) -> URLSessionTask?
    
    init<T: _LyricsProvider>(_ provider: T) {
        _searchTask = { req, callback in
            return provider.searchTask(request: req, completionHandler: { tokens in
                callback(tokens)
            })
        }
        _fetchTask = { token, callback in
            return provider.fetchTask(token: token as! T.LyricsToken, completionHandler: callback)
        }
    }
    
    func searchTask(request: LyricsSearchRequest, completionHandler: @escaping ([Any]) -> Void) -> URLSessionTask? {
        return _searchTask(request, completionHandler)
    }
    
    func fetchTask(token: Any, completionHandler: @escaping (Lyrics?) -> Void) -> URLSessionTask? {
        return _fetchTask(token, completionHandler)
    }
}

public class DistributedLyricsSearchTask {
    
    public enum State {
        case pending
        case searching
        case fetching
        case canceling
        case completed
    }
    
    public let request: LyricsSearchRequest
    public var state: State
    public var progress = Progress()
    
    var urlTasks: [URLSessionTask] = []
    var provider: _AnyLyricsProvider
    var handler: (Lyrics) -> Void
    
    init(request: LyricsSearchRequest, provider: _AnyLyricsProvider, handler: @escaping (Lyrics) -> Void) {
        self.request = request
        self.state = .pending
        self.provider = provider
        self.handler = handler
    }
    
    func resume() {
        guard case .pending = state else { return }
        guard let searchTask = provider.searchTask(request: request, completionHandler: self.searchComplete) else {
            state = .completed
            progress.completedUnitCount = 1
            return
        }
        urlTasks.append(searchTask)
        searchTask.resume()
    }
    
    func cancel() {
        state = .canceling
        urlTasks.forEach { $0.cancel() }
    }
    
    private func searchComplete(tokens: [Any]) {
        state = .fetching
        let tasks = Array(tokens.enumerated().flatMap { (idx, token) in
            provider.fetchTask(token: token) { lrc in
                lrc?.metadata.searchIndex = idx
                self.fetchComplete(lyrics: lrc)
            }
        }.prefix(request.limit))
        progress.totalUnitCount += Int64(tasks.count)
        progress.completedUnitCount = 1
        guard !tasks.isEmpty else {
            state = .completed
            return
        }
        urlTasks += tasks
        urlTasks.forEach { $0.resume() }
    }
    
    private func fetchComplete(lyrics: Lyrics?) {
        if let lyrics = lyrics {
            lyrics.metadata.title = request.title
            lyrics.metadata.artist = request.artist
            lyrics.idTags[.recreater] = "LyricsX"
            lyrics.idTags[.version] = "1"
            handler(lyrics)
        }
        progress.completedUnitCount += 1
        if progress.fractionCompleted == 1 {
            state = .completed
        }
    }
}
