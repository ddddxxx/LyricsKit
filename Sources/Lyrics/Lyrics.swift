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

private let lyricsLinePattern = "^(\\[[+-]?\\d+:\\d+(?:.\\d+)?\\])+(?!\\[)([^【\\n]*)(?:【(.*)】)?"
private let lyricsLineRegex = try! NSRegularExpression(pattern: lyricsLinePattern)

private let lyricsLineAttachmentPattern = "^(\\[[+-]?\\d+:\\d+(?:.\\d+)?\\])+\\[(.+?)\\](.*)"
private let lyricsLineAttachmentRegex = try! NSRegularExpression(pattern: lyricsLineAttachmentPattern)

private let id3TagPattern = "^\\[(.+):(.*)\\](?=\\n)"
private let id3TagRegex = try! NSRegularExpression(pattern: id3TagPattern)

final public class Lyrics: LosslessStringConvertible {
    
    public var lines: [LyricsLine] = []
    public var idTags: [IDTagKey: String] = [:]
    public var metadata: MetaData = MetaData()
    
    public init?(_ description: String) {
        id3TagRegex.matches(in: description).forEach { match in
            if let key = description[match.range(at: 1)]?.trimmingCharacters(in: .whitespaces),
                let value = description[match.range(at: 2)]?.trimmingCharacters(in: .whitespaces) {
                idTags[.init(key)] = value
            }
        }
        
        lines = lyricsLineRegex.matches(in: description).flatMap { match -> [LyricsLine] in
            let timeTagStr = description[match.range(at: 1)]!
            let timeTags = resolveTimeTag(timeTagStr)
            
            let lyricsContentStr = description[match.range(at: 2)]!
            var line = LyricsLine(content: lyricsContentStr, position: 0)
            
            if let translationStr = description[match.range(at: 3)] {
                let translationAttachment = LyricsLineAttachmentPlainText(translationStr)
                line.attachments[.translation] = translationAttachment
            }
            
            return timeTags.map { timeTag in
                var l = line
                l.position = timeTag
                l.lyrics = self
                return l
            }
        }.sorted {
            $0.position < $1.position
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
        
        lyricsLineAttachmentRegex.matches(in: description).forEach { match in
            let timeTagStr = description[match.range(at: 1)]!
            let timeTags = resolveTimeTag(timeTagStr)
            
            let attachmentTagStr = description[match.range(at: 2)]!
            let attachmentTag = LyricsLineAttachmentTag(attachmentTagStr)
            
            let attachmentStr = description[match.range(at: 3)] ?? ""
            guard let attachment = LyricsLineAttachmentFactory.createAttachment(str: attachmentStr, tag: attachmentTag) else {
                return
            }
            
            for timeTag in timeTags {
                guard let index = indexOf(position: timeTag) else {
                    continue
                }
                lines[index].attachments[attachmentTag] = attachment
            }
            metadata.attachmentTags.insert(attachmentTag)
        }
        
        guard !lines.isEmpty else {
            return nil
        }
    }
    
    public var description: String {
        let components = idTags.map { "[\($0.key.rawValue):\($0.value)]" }
            + lines.map { $0.description }
        return components.joined(separator: "\n")
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
        
        public var source: Source = .Unknown
        public var title: String? = nil
        public var artist: String? = nil
        public var searchBy: SearchTerm? = nil
        public var searchIndex: Int = 0
        public var lyricsURL: URL? = nil
        public var artworkURL: URL? = nil
        public var attachmentTags: Set<LyricsLineAttachmentTag> = []
        
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
}

extension Lyrics {
    
    public func filtrate(isIncluded predicate: NSPredicate) {
        for (index, lyric) in lines.enumerated() {
            lines[index].enabled = !predicate.evaluate(with: lyric)
        }
    }
    
    public func smartFiltrate() {
        let predicate = NSPredicate { (object, _) -> Bool in
            guard let object = object as? LyricsLine else {
                return false
            }
            let content = object.content
            if let idTagTitle = self.idTags[.title],
                let idTagArtist = self.idTags[.artist],
                content.contains(idTagTitle),
                content.contains(idTagArtist) {
                return false
            } else if let iTunesTitle = self.metadata.title,
                let iTunesArtist = self.metadata.artist,
                content.contains(iTunesTitle),
                content.contains(iTunesArtist) {
                return false
            }
            return true
        }
        filtrate(isIncluded: predicate)
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
        return Mirror(reflecting: self).children.map { "[\($0!):\($1)]" }.joined(separator: "\n")
    }
}

extension Lyrics.IDTagKey: CustomStringConvertible {
    
    public var description: String {
        return rawValue
    }
}
