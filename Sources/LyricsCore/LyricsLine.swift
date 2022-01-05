//
//  LyricsLine.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public struct LyricsLine {
    
    public var content: String
    public var position: TimeInterval
    public var attachments: Attachments
    
    public weak var lyrics: Lyrics?
    internal var _index: Int?
    
    public var timeTag: String {
        let min = Int(position / 60)
        let sec = position - TimeInterval(min * 60)
        return String(format: "%02d:%06.3f", min, sec)
    }
    
    public init(content: String, position: TimeInterval, attachments: Attachments = Attachments()) {
        self.content = content
        self.position = position
        self.attachments = attachments
    }
}

extension LyricsLine {
    
    public func previousLine() -> LyricsLine? {
        guard let lyrics = self.lyrics, let index = self._index else {
            return nil
        }
        let resultIndex = index - 1
        guard lyrics.indices.contains(resultIndex) else {
            return nil
        }
        return lyrics[resultIndex]
    }
    
    public func nextLine() -> LyricsLine? {
        guard let lyrics = self.lyrics, let index = self._index else {
            return nil
        }
        let resultIndex = index + 1
        guard lyrics.indices.contains(resultIndex) else {
            return nil
        }
        return lyrics[resultIndex]
    }
}

extension LyricsLine: Equatable, Hashable {
    
    public static func ==(lhs: LyricsLine, rhs: LyricsLine) -> Bool {
        return lhs.position == rhs.position &&
            lhs.content == rhs.content &&
            lhs.attachments == rhs.attachments
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(position)
        hasher.combine(content)
    }
}

extension LyricsLine: CustomStringConvertible {
    
    public var description: String {
        return ([content] + attachments.content.map { "[\($0.key)]\($0.value)" }).map {
            "[\(timeTag)]\($0)"
        }.joined(separator: "\n")
    }
}
