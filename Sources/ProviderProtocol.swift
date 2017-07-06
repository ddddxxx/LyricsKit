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

public protocol LyricsProvider {
    
    func searchLyrics(criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, using: @escaping (Lyrics) -> Void, completionHandler: @escaping () -> Void)
    
    func iFeelLucky(criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, completionHandler: @escaping (Lyrics?) -> Void)
    
    func cancelSearch()
}

protocol MultiResultLyricsProvider: LyricsProvider {
    
    associatedtype LyricsToken
    
    var session: URLSession { get }
    var dispatchGroup: DispatchGroup { get }
    
    func searchLyricsToken(criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, completionHandler: @escaping ([LyricsToken]) -> Void)
    
    func getLyricsWithToken(token: LyricsToken, completionHandler: @escaping (Lyrics?) -> Void)
}

protocol SingleResultLyricsProvider: LyricsProvider {
    
    var session: URLSession { get }
}

extension MultiResultLyricsProvider {
    
    public func searchLyrics(criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, using: @escaping (Lyrics) -> Void, completionHandler: @escaping () -> Void) {
        dispatchGroup.enter()
        searchLyricsToken(criteria: criteria, duration: duration) { tokens in
            tokens.enumerated().forEach { index, token in
                self.dispatchGroup.enter()
                self.getLyricsWithToken(token: token) { lyrics in
                    if let lyrics = lyrics {
                        lyrics.metadata.searchIndex = index
                        using(lyrics)
                    }
                    self.dispatchGroup.leave()
                }
            }
            self.dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .global(), execute: completionHandler)
    }
    
    public func iFeelLucky(criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, completionHandler: @escaping (Lyrics?) -> Void) {
        searchLyricsToken(criteria: criteria, duration: duration) { tokens in
            guard let token = tokens.first else {
                completionHandler(nil)
                return
            }
            self.getLyricsWithToken(token: token, completionHandler: completionHandler)
        }
    }
    
    public func cancelSearch() {
        session.getTasksWithCompletionHandler() { dataTasks, _, _ in
            dataTasks.forEach {
                $0.cancel()
            }
        }
    }
}

extension SingleResultLyricsProvider {
    
    public func searchLyrics(criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, using: @escaping (Lyrics) -> Void, completionHandler: @escaping () -> Void) {
        iFeelLucky(criteria: criteria, duration: duration) {
            if let lyrics = $0 {
                using(lyrics)
            }
            completionHandler()
        }
    }
    
    public func cancelSearch() {
        session.getTasksWithCompletionHandler() { dataTasks, _, _ in
            dataTasks.forEach {
                $0.cancel()
            }
        }
    }
}

extension CharacterSet {
    
    static var uriComponentAllowed: CharacterSet {
        let unsafe = CharacterSet(charactersIn: "!*'();:&=+$,[]~")
        return CharacterSet.urlHostAllowed.subtracting(unsafe)
    }
}

extension URLSessionConfiguration {
    
    static let providerConfig = URLSessionConfiguration.default.with {
        $0.timeoutIntervalForRequest = 10
    }
}

extension URLRequest: Then {}
