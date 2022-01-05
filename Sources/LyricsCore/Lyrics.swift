//
//  Lyrics.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

final public class Lyrics {
    
    private var lines: [LyricsLine] = []
    public var idTags: [IDTagKey: String] = [:]
    public var metadata: Metadata = Metadata()
    
    public init(lines: [LyricsLine], idTags: [IDTagKey: String], metadata: Metadata = Metadata()) {
        self.lines = lines
        self.idTags = idTags
        self.metadata = metadata
        for idx in self.lines.indices {
            self.lines[idx].lyrics = self
            self.lines[idx]._index = idx
        }
        self.metadata.attachmentTags = Set(self.lines.flatMap(\.attachments.content.keys))
    }
}

extension Lyrics: RandomAccessCollection {
    
    public var startIndex: Int {
        return lines.startIndex
    }
    
    public var endIndex: Int {
        return lines.endIndex
    }
    
    public subscript(position: Int) -> LyricsLine {
        _read {
            yield lines[position]
        }
        _modify {
            yield &lines[position]
        }
    }
}

extension Lyrics: LosslessStringConvertible {
    
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
                if case let .found(at: index) = searchLine(at: timeTag) {
                    self.lines[index].attachments[.init(attachmentTagStr)] = attachmentStr
                }
            }
            tags.insert(.init(attachmentTagStr))
        }
        metadata.attachmentTags = tags
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
}

extension Lyrics {
    
    private enum Match {
        case found(at: Int)
        case notFound(insertAt: Int)
    }
    
    private func searchLine(at position: TimeInterval) -> Match {
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
    
    /// Get current lyrics line with playback position. with lyrics offset considered.
    /// - Returns: lyrics line index at specified position, or nil if all lines are after the position.
    public func lineIndex(at position: TimeInterval) -> Int? {
        let delayedPosition = position + timeDelay
        switch searchLine(at: delayedPosition) {
        case let .found(at: i): return i
        case let .notFound(insertAt: i): return lines.index(i, offsetBy: -1, limitedBy: lines.startIndex)
        }
    }
}
