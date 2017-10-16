//
//  Lyrics+Compare.swift
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

infix operator ?>
private func ?>(lhs: Bool?, rhs: Bool?) -> Bool? {
    switch (lhs, rhs) {
    case (true?, true?), (false?, false?):
        return nil
    case (true?, _), (_, false?):
        return true
    case (_, true?), (false?, _):
        return false
    default:
        return nil
    }
}

extension Lyrics {
    
    public static func >(lhs: Lyrics, rhs: Lyrics) -> Bool {
        if lhs.metadata.source == rhs.metadata.source  {
            return lhs.metadata.searchIndex < rhs.metadata.searchIndex
        }
        
        if let artistComparison = lhs.isFitArtist ?> rhs.isFitArtist {
            return artistComparison
        }
        
        if let artistComparison = lhs.isApproachArtise ?> rhs.isApproachArtise {
            return artistComparison
        }
        
        if let titleComparison = lhs.isFitTitle ?> rhs.isFitTitle {
            return titleComparison
        }
        
        if let titleComparison = lhs.isApproachTitle ?> rhs.isApproachTitle {
            return titleComparison
        }
        
        if let translationComparison = lhs.metadata.attachmentTags.contains(.translation) ?> rhs.metadata.attachmentTags.contains(.translation) {
            return translationComparison
        }
        
        return false
    }
    
    public static func <(lhs: Lyrics, rhs: Lyrics) -> Bool {
        return rhs > lhs
    }
    
    public static func >=(lhs: Lyrics, rhs: Lyrics) -> Bool {
        return !(lhs < rhs)
    }
    
    public static func <=(lhs: Lyrics, rhs: Lyrics) -> Bool {
        return !(lhs > rhs)
    }
    
    private var isFitArtist: Bool? {
        guard case let .info(_, searchArtist)? = metadata.searchBy,
            let artist = idTags[.artist] else {
                return nil
        }
        
        return searchArtist.lowercased() == artist.lowercased()
    }
    
    private var isApproachArtise: Bool? {
        guard case let .info(_, searchArtist)? = metadata.searchBy,
            let artist = idTags[.artist] else {
                return nil
        }
        
        let s1 = searchArtist.lowercased().replacingOccurrences(of: " ", with: "")
        let s2 = artist.lowercased().replacingOccurrences(of: " ", with: "")
        
        return s1.contains(s2) || s2.contains(s1)
    }
    
    private var isFitTitle: Bool? {
        guard case let .info(searchTitle, _)? = metadata.searchBy,
            let title = idTags[.title] else {
                return nil
        }
        
        return searchTitle.lowercased() == title.lowercased()
    }
    
    private var isApproachTitle: Bool? {
        guard case let .info(searchTitle, _)? = metadata.searchBy,
            let title = idTags[.title] else {
                return nil
        }
        
        let s1 = searchTitle.lowercased().replacingOccurrences(of: " ", with: "")
        let s2 = title.lowercased().replacingOccurrences(of: " ", with: "")
        
        return s1.contains(s2) || s2.contains(s1)
    }
}
