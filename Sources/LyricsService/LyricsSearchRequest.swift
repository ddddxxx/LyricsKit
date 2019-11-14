//
//  LyricsSearchRequest.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
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
