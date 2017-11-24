//
//  LyricsSearchRequest.swift
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

public struct LyricsSearchRequest {
    
    public var searchTerm: SearchTerm
    public var title: String
    public var artist: String
    public var duration: TimeInterval
    
    public enum SearchTerm {
        
        case keyword(String)
        case info(title: String, artist: String)
    }
}

extension LyricsSearchRequest: Equatable {
    
    public static func ==(lhs: LyricsSearchRequest, rhs: LyricsSearchRequest) -> Bool {
        return lhs.searchTerm == rhs.searchTerm &&
            lhs.title == rhs.title &&
            lhs.artist == rhs.artist &&
            lhs.duration == rhs.duration
    }
}

extension LyricsSearchRequest.SearchTerm: Equatable {
    
    public static func ==(lhs: LyricsSearchRequest.SearchTerm, rhs: LyricsSearchRequest.SearchTerm) -> Bool {
        switch (lhs, rhs) {
        case (.keyword, .info), (.info, .keyword):
            return false
        case (let .keyword(l), let .keyword(r)):
            return l == r
        case (let .info(l1, l2), let .info(r1, r2)):
            return (l1 == r1) && (l2 == r2)
        }
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
