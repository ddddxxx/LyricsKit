//
//  Lyrics.swift
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

public class Lyrics {
    
    public var lines: [LyricsLine]
    public var idTags: [IDTagKey: String]
    public var metadata: MetaData
    
    public var offset: Int {
        get {
            return idTags[.offset].flatMap { Int($0) } ?? 0
        }
        set {
            idTags[.offset] = "\(newValue)"
        }
    }
    
    public var timeDelay: TimeInterval {
        get {
            return TimeInterval(offset) / 1000
        }
        set {
            offset = Int(newValue * 1000)
        }
    }
    
    private static let idTagRegex = try! NSRegularExpression(pattern: "\\[[^\\]]+:[^\\]]+\\]")
    private static let timeTagRegex = try! NSRegularExpression(pattern: "\\[\\d+:\\d+.\\d+\\]|\\[\\d+:\\d+\\]")
    
    public init?(_ lrcContents: String) {
        lines = []
        idTags = [:]
        metadata = MetaData(source: .Unknown)
        
        var tempAttechment: [(TimeInterval, LyricsLineAttachmentTag, LyricsLineAttachment)] = []
        
        let lyricsLines = lrcContents.components(separatedBy: .newlines)
        for line in lyricsLines {
            if let attechment = resolveLyricsLineAttachment(line) {
                tempAttechment += attechment
                continue
            }
            if let l = resolveLyricsLine(line) {
                lines += l
                continue
            }
            if let tag = resolveID3Tag(line) {
                idTags[tag.0] = tag.1
                continue
            }
            // TODO: unresolved lines
        }
        
        guard !lines.isEmpty else {
            return nil
        }
        
        lines.sort {
            $0.position < $1.position
        }
        
        for index in 0..<lines.count {
            lines[index].lyrics = self
        }
        
        func indexOf(position: TimeInterval) -> Int? {
            var left = lines.startIndex
            var right = lines.endIndex - 1
            while left <= right {
                let mid = (left + right) / 2
                if lines[mid].position < position {
                    left = mid + 1
                } else if lines[mid].position > position {
                    right = mid - 1
                } else {
                    return mid
                }
            }
            return nil
        }
        
        for attechment in tempAttechment {
            guard let index = indexOf(position: attechment.0) else {
                return nil
            }
            lines[index].attachment[attechment.1] = attechment.2
        }
    }
    
    public subscript(_ position: TimeInterval) -> (current:LyricsLine?, next:LyricsLine?) {
        let position = position + timeDelay
        var left = lines.startIndex
        var right = lines.endIndex - 1
        while left <= right {
            let mid = (left + right) / 2
            if lines[mid].position <= position {
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        
        let current = right < 0 ? nil : lines[lines.startIndex...right].reversed().first { $0.enabled }
        let next = lines[left..<lines.endIndex].first { $0.enabled }
        return (current, next)
    }
    
    public struct IDTagKey: RawRepresentable, Hashable {
        
        public var rawValue: String
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public var hashValue: Int {
            return rawValue.hash
        }
        
        public static let title    = IDTagKey("ti")
        public static let album    = IDTagKey("al")
        public static let artist   = IDTagKey("ar")
        public static let author   = IDTagKey("au")
        public static let lrcBy    = IDTagKey("by")
        public static let offset   = IDTagKey("offset")
        public static let recreater = IDTagKey("re")
        public static let version  = IDTagKey("ve")
    }
    
    public struct MetaData {
        
        public var source: Source
        public var title: String?
        public var artist: String?
        public var searchBy: SearchTerm?
        public var searchIndex: Int
        public var lyricsURL: URL?
        public var artworkURL: URL?
        public var includeTranslation: Bool
        
        public init(source: Source, title: String? = nil, artist: String? = nil, searchBy: SearchTerm? = nil, searchIndex: Int = 0, lyricsURL: URL? = nil, artworkURL: URL? = nil, includeTranslation: Bool = false) {
            self.source = source
            self.title = title
            self.artist = artist
            self.searchBy = searchBy
            self.searchIndex = searchIndex
            self.lyricsURL = lyricsURL
            self.artworkURL = artworkURL
            self.includeTranslation = includeTranslation
        }
        
        public struct Source: RawRepresentable {
            
            public var rawValue: String
            
            public init(rawValue: String) {
                self.rawValue = rawValue
            }
            
            public init(_ rawValue: String) {
                self.rawValue = rawValue
            }
            
            public static let Unknown = Source("Unknown")
            public static let Local = Source("Local")
            public static let Import = Source("Import")
        }
        
        public enum SearchTerm {
            
            case keyword(String)
            case info(title: String, artist: String)
        }
    }
}

extension Lyrics {
    
    public func contentString(withMetadata: Bool, ID3: Bool, timeTag: Bool, translation: Bool) -> String {
        var content = ""
        if withMetadata {
            content += metadata.description
        }
        if ID3 {
            content += idTags.map {
                return "[\($0.key.rawValue):\($0.value)]\n"
            }.joined()
        }
        
        content += lines.map {
            return $0.contentString(withTimeTag: timeTag, translation: translation) + "\n"
        }.joined()
        
        return content
    }
}

extension Lyrics {
    
    public func filtrate(using regex: NSRegularExpression) {
        for (index, lyric) in lines.enumerated() {
            let content = lyric.content.replacingOccurrences(of: " ", with: "")
            let numberOfMatches = regex.numberOfMatches(in: content, options: [], range: content.range)
            if numberOfMatches > 0 {
                lines[index].enabled = false
                continue
            }
        }
    }
    
    public func smartFiltrate() {
        for (index, lyric) in lines.enumerated() {
            let content = lyric.content
            if let idTagTitle = idTags[.title],
                let idTagArtist = idTags[.artist],
                content.contains(idTagTitle),
                content.contains(idTagArtist) {
                lines[index].enabled = false
            } else if let iTunesTitle = metadata.title,
                let iTunesArtist = metadata.artist,
                content.contains(iTunesTitle),
                content.contains(iTunesArtist) {
                lines[index].enabled = false
            }
        }
    }
}

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
        
        if let translationComparison = lhs.metadata.includeTranslation ?> rhs.metadata.includeTranslation {
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
        
        return searchArtist == artist
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
        
        return searchTitle == title
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

// MARK: - Equatable

extension Lyrics.MetaData.Source: Equatable {
    public static func ==(lhs: Lyrics.MetaData.Source, rhs: Lyrics.MetaData.Source) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension Lyrics.MetaData.SearchTerm: Equatable {
    public static func ==(lhs: Lyrics.MetaData.SearchTerm, rhs: Lyrics.MetaData.SearchTerm) -> Bool {
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

// MARK: CustomStringConvertible

extension Lyrics.MetaData.SearchTerm: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .keyword(keyword):
            return keyword
        case let .info(title: title, artist: artist):
            return title + " " + artist
        }
    }
}

extension Lyrics.MetaData: CustomStringConvertible {
    
    public var description: String {
        return Mirror(reflecting: self).children.map { "[\($0!):\($1)]\n" }.joined()
    }
}

extension Lyrics.IDTagKey: CustomStringConvertible {
    
    public var description: String {
        return rawValue
    }
}

extension Lyrics: CustomStringConvertible {
    
    public var description: String {
        return contentString(withMetadata: true, ID3: true, timeTag: true, translation: true)
    }
}
