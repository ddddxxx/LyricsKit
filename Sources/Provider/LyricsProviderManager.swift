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

public class LyricsProviderManager {
    
    let queue: OperationQueue
    let session: URLSession
    let providers: [LyricsProvider]
    
    public init(sources: [LyricsProviderSource] = LyricsProviderSource.allCases) {
        let queue = OperationQueue()
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: queue)
        let providers = sources.map { $0.cls.init(session: session) }
        
        queue.maxConcurrentOperationCount = 1
        
        self.queue = queue
        self.session = session
        self.providers = providers
    }
    
    public func searchLyrics(request: LyricsSearchRequest, using: @escaping (Lyrics) -> Void) -> Progress {
        let progress = Progress(totalUnitCount: Int64(providers.count))
        for provider in providers {
            let child = provider.lyricsTask(request: request, using: using)
            progress.addChild(child, withPendingUnitCount: 1)
        }
        return progress
    }
}
