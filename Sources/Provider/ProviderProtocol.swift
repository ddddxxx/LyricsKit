//
//  ProviderProtocol.swift
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

protocol LyricsProvider {
    
    init(session: URLSession)
    
    func lyricsTask(request: LyricsSearchRequest, using: @escaping (Lyrics) -> Void) -> Progress
}

protocol _LyricsProvider: LyricsProvider {
    
    associatedtype LyricsToken
    
    func searchTask(request: LyricsSearchRequest, completionHandler: @escaping ([LyricsToken]) -> Void) -> Progress
    
    func fetchTask(token: LyricsToken, completionHandler: @escaping (Lyrics?) -> Void) -> Progress
}

extension _LyricsProvider {
    
    public func lyricsTask(request: LyricsSearchRequest, using: @escaping (Lyrics) -> Void) -> Progress {
        let progress = Progress(parent: Progress.current())
        progress.totalUnitCount = 100
        let searchProgress = searchTask(request: request) { tokens in
            let count = min(tokens.count, request.limit)
            let fetchProgress = Progress(totalUnitCount: Int64(count), parent: progress, pendingUnitCount: 80)
            tokens.prefix(request.limit).enumerated().forEach { (idx, token) in
                let child = self.fetchTask(token: token) { lrc in
                    guard let lrc = lrc else { return }
                    lrc.metadata.searchIndex = idx
                    using(lrc)
                }
                fetchProgress.addChild(child, withPendingUnitCount: 1)
            }
        }
        progress.addChild(searchProgress, withPendingUnitCount: 20)
        return progress
    }
}
