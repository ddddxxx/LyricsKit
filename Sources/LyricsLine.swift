//
//  LyricsLine.swift
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

public struct LyricsLine {
    
    public var sentence: String
    public var attachment: [AttachmentType: LyricsLineAttachment] = [:]
    public var position: TimeInterval
    public var enabled: Bool = true
    
//    public var
    
    public var timeTag: String {
        let min = Int(position / 60)
        let sec = position - TimeInterval(min * 60)
        return String(format: "%02d:%06.3f", min, sec)
    }
    
    public init(sentence: String, position: TimeInterval) {
        self.sentence = sentence
        self.position = position
        normalization()
    }
    
    public init?(sentence: String, timeTag: String) {
        var tagContent = timeTag
        tagContent.remove(at: tagContent.startIndex)
        tagContent.remove(at: tagContent.index(before: tagContent.endIndex))
        let components = tagContent.components(separatedBy: ":")
        if components.count == 2,
            let min = TimeInterval(components[0]),
            let sec = TimeInterval(components[1]) {
            let position = sec + min * 60
            self.init(sentence: sentence, position: position)
        } else {
            return nil
        }
    }
    
    private static let serialWhiteSpacesRegex = try! NSRegularExpression(pattern: "( )+")
    
    private mutating func normalization() {
        sentence = sentence.trimmingCharacters(in: .whitespaces)
        sentence = LyricsLine.serialWhiteSpacesRegex.stringByReplacingMatches(in: sentence, options: [], range: sentence.range, withTemplate: " ")
        if sentence == "." {
            sentence = ""
        }
    }
}

public protocol LyricsLineAttachment {
    var stringRepresentation: String { get }
}

public extension LyricsLine {
    
    public struct AttachmentType: RawRepresentable {
        
        public var rawValue: String
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(rawValue: String) {
            self.init(rawValue)
        }
        
        static let translation = AttachmentType("translation")
    }
    
    public struct AttachmentTranslation: LyricsLineAttachment {
        
        public var translation: String
        
        public var stringRepresentation: String {
            return translation
        }
    }
}

extension LyricsLine.AttachmentType: Equatable, Hashable {
    
    public var hashValue: Int {
        return rawValue.hashValue
    }
    
    public static func ==(lhs: LyricsLine.AttachmentType, rhs: LyricsLine.AttachmentType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension LyricsLine: Equatable, Hashable {
    
    public var hashValue: Int {
        return sentence.hashValue ^ position.hashValue
    }
    
    public static func ==(lhs: LyricsLine, rhs: LyricsLine) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension LyricsLine {
    
    public func contentString(withTimeTag: Bool, translation: Bool) -> String {
        var content = ""
        if withTimeTag {
            content += "[" + timeTag + "]"
        }
        content += sentence
        return content
    }
}

extension LyricsLine: CustomStringConvertible {
    
    public var description: String {
        return contentString(withTimeTag: true, translation: true)
    }
}

extension String {
    
    var range: NSRange {
        return NSRange(location: 0, length: characters.count)
    }
}
