//
//  LyricsSearchRequest.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public struct LyricsSearchRequest: Equatable {
    
    public var searchTerm: SearchTerm
    public var title: String
    public var artist: String
    public var duration: TimeInterval
    public var limit: Int
    public var timeout: TimeInterval
    
    public enum SearchTerm: Equatable {
        case keyword(String)
        case info(title: String, artist: String)
    }
    
    public init(searchTerm: SearchTerm, title: String, artist: String, duration: TimeInterval, limit: Int = 6, timeout: TimeInterval = 10) {
        self.searchTerm = searchTerm
        self.title = title
        self.artist = artist
        self.duration = duration
        self.limit = limit
        self.timeout = timeout
    }
}

extension LyricsSearchRequest.SearchTerm: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .keyword(keyword):
            return keyword
        case let .info(title: title, artist: artist):
            return title + " " + artist
        }
    }
}
