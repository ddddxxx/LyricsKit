//
//  Lyrics.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

final public class Lyrics: LosslessStringConvertible {
    
    public var lines: [LyricsLine] = []
    public var idTags: [IDTagKey: String] = [:]
    public var metadata: Metadata = Metadata()
    
    public init(lines: [LyricsLine], idTags: [IDTagKey: String], metadata: Metadata = Metadata()) {
        self.lines = lines
        self.idTags = idTags
        self.metadata = metadata
        for idx in self.lines.indices {
            self.lines[idx].lyrics = self
        }
        self.metadata.attachmentTags = Set(self.lines.flatMap(\.attachments.content.keys))
    }
    
    public convenience init?(_ description: String) {
        var idTags: [IDTagKey: String] = [:]
        id3TagRegex.matches(in: description).forEach { match in
            if let key = match[1]?.content.trimmingCharacters(in: .whitespaces),
                let value = match[2]?.content.trimmingCharacters(in: .whitespaces),
                !value.isEmpty {
                idTags[.init(key)] = value
            }
        }
        
        let lines = lyricsLineRegex.matches(in: description).flatMap { match -> [LyricsLine] in
            let timeTagStr = match[1]!.string
            let timeTags = resolveTimeTag(timeTagStr)
            
            let lyricsContentStr = match[2]!.string
            var line = LyricsLine(content: lyricsContentStr, position: 0)
            
            if let translationStr = match[3]?.string, !translationStr.isEmpty {
                line.attachments[.translation()] = translationStr
            }
            
            return timeTags.map { timeTag in
                var l = line
                l.position = timeTag
                return l
            }
        }.sorted {
            $0.position < $1.position
        }
        
        guard !lines.isEmpty else {
            return nil
        }
        self.init(lines: lines, idTags: idTags)
        
        var tags: Set<LyricsLine.Attachments.Tag> = []
        lyricsLineAttachmentRegex.matches(in: description).forEach { match in
            let timeTagStr = match[1]!.string
            let timeTags = resolveTimeTag(timeTagStr)
            
            let attachmentTagStr = match[2]!.string
            let attachmentStr = match[3]?.string ?? ""
            
            for timeTag in timeTags {
                if case let .found(at: index) = lineIndex(of: timeTag) {
                    self.lines[index].attachments[.init(attachmentTagStr)] = attachmentStr
                }
            }
            tags.insert(.init(attachmentTagStr))
        }
        metadata.data[.attachmentTags] = tags
    }
    
    public var description: String {
        let components = idTags.map { "[\($0.key.rawValue):\($0.value)]" }
            + lines.map(\.description)
        return components.joined(separator: "\n")
    }
    
    public var legacyDescription: String {
        let components = idTags.map { "[\($0.key.rawValue):\($0.value)]" } + lines.map { "[\($0.timeTag)]\($0.content)" + ($0.attachments.translation().map { "【\($0)】" } ?? "") }
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
        
        public static let title = IDTagKey("ti")
        public static let album = IDTagKey("al")
        public static let artist = IDTagKey("ar")
        public static let author = IDTagKey("au")
        public static let lrcBy = IDTagKey("by")
        public static let offset = IDTagKey("offset")
        public static let length = IDTagKey("length")
    }
    
    public struct Metadata {
        
        public var data: [Key: Any]
        
        public init(data: [Key: Any] = [:]) {
            self.data = data
        }
        
        public struct Key: RawRepresentable, Hashable {
            
            public var rawValue: String
            
            public init(_ rawValue: String) {
                self.rawValue = rawValue
            }
            
            public init(rawValue: String) {
                self.rawValue = rawValue
            }
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
    
    public var length: TimeInterval? {
        get {
            guard let len = idTags[.length],
                let match = base60TimeRegex.firstMatch(in: len) else {
                    return nil
            }
            let min = (match[1]?.content).flatMap(Double.init) ?? 0
            let sec = Double(match[2]!.content) ?? 0
            return min * 60 + sec
        }
        set {
            guard let newValue = newValue else {
                idTags.removeValue(forKey: .length)
                return
            }
            let fmt = NumberFormatter()
            fmt.minimumFractionDigits = 0
            fmt.maximumFractionDigits = 2
            let str = fmt.string(from: newValue as NSNumber)
            idTags[.length] = str
        }
    }
    
    fileprivate enum Match {
        case found(at: Int)
        case notFound(insertAt: Int)
    }
    
    fileprivate func lineIndex(of position: TimeInterval) -> Match {
        var left = 0
        var right = lines.count - 1
        
        while left <= right {
            let mid = (left + right) / 2
            let candidate = lines[mid]
            if candidate.position < position {
                left = mid + 1
            } else if position < candidate.position {
                right = mid - 1
            } else {
                return .found(at: mid)
            }
        }
        return .notFound(insertAt: left)
    }
    
    public subscript(_ position: TimeInterval) -> (currentLineIndex:Int?, nextLineIndex:Int?) {
        let index: Int
        switch lineIndex(of: position) {
        case let .found(at: i): index = i + 1
        case let .notFound(insertAt: i): index = i
        }
        let current = (0..<index).reversed().first { lines[$0].enabled }
        let next = lines[index...].firstIndex(where: \.enabled)
        return (current, next)
    }
}

extension Lyrics {
    
    public func filtrate(isIncluded predicate: NSPredicate) {
        for (index, lyric) in lines.enumerated() {
            if !predicate.evaluate(with: lyric) {
                lines[index].enabled = false
            }
        }
    }
}

// MARK: CustomStringConvertible

extension Lyrics.Metadata: CustomStringConvertible {
    
    public var description: String {
        return Mirror(reflecting: self).children.map { "[\($0!):\($1)]" }.joined(separator: "\n")
    }
}

extension Lyrics.IDTagKey: CustomStringConvertible {
    
    public var description: String {
        return rawValue
    }
}
