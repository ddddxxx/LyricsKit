//
//  LyricsLineAttachmentRangeAttribute.swift
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

public struct LyricsLineAttachmentRangeAttribute: LyricsLineAttachment {
    
    public struct Tag {
        
        public var content: String
        public var range: Range<Int>
        
        public init(content: String, range: Range<Int>) {
            self.content = content
            self.range = range
        }
    }
    
    public var attachment: [Tag]
    
    public var description: String {
        return attachment.map { $0.description }.joined()
    }
    
    static private let rangeAttachmentPattern = "<([^,]+,\\d+,\\d+)>"
    static private let rangeAttachmentRegex = try! NSRegularExpression(pattern: rangeAttachmentPattern)
    
    public init?(_ description: String) {
        let matchs = LyricsLineAttachmentRangeAttribute.rangeAttachmentRegex.matches(in: description)
        attachment = matchs.flatMap { Tag(description[$0.range(at: 1)]!) }
        guard !attachment.isEmpty else {
            return nil
        }
    }
}

extension LyricsLineAttachmentRangeAttribute.Tag: LosslessStringConvertible {
    
    public var description: String {
        return "<\(content),\(range.lowerBound),\(range.upperBound)>"
    }
    
    public init?(_ description: String) {
        let components = description.components(separatedBy: ",")
        guard components.count == 3,
            let lb = Int(components[1]),
            let ub = Int(components[2]),
            lb < ub else {
                return nil
        }
        self.content = components[0]
        self.range = lb..<ub
    }
}
