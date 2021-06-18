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
    public var duration: TimeInterval
    public var limit: Int
    public var userInfo: [String: String]
    
    public enum SearchTerm: Equatable {
        case keyword(String)
        case info(title: String, artist: String)
    }
    
    public init(searchTerm: SearchTerm, duration: TimeInterval, limit: Int = 6, userInfo: [String: String] = [:]) {
        self.searchTerm = searchTerm
        self.duration = duration
        self.limit = limit
        self.userInfo = userInfo
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
