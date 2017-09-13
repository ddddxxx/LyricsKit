//
//  LyricsLineAttachmentTimeLine.swift
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

public struct LyricsLineAttachmentTimeLine: LyricsLineAttachment {
    
    public struct Tag {
        public var index: Int
        public var timeTag: TimeInterval  // since the line begin
        
        public var timeTagMSec: Int {
            get { return Int(timeTag * 1000) }
            set { timeTag = TimeInterval(newValue) / 1000 }
        }
        
        public init(timeTag: TimeInterval, index: Int) {
            self.timeTag = timeTag
            self.index = index
        }
    }
    
    public var attachment: [Tag]
    public var duration: TimeInterval?
    
    public var durationMSec: Int? {
        get { return duration.map { Int($0 * 1000) } }
        set { duration = newValue.map { TimeInterval($0) / 1000 } }
    }
    
    public var description: String {
        var result = attachment.map { $0.description }.joined()
        if let duration = duration {
            result += "<\(duration)?"
        }
        return result
    }
    
    static private let timeLineAttachmentPattern = "<(\\d+,\\d+)>"
    static private let timeLineAttachmentRegex = try! NSRegularExpression(pattern: timeLineAttachmentPattern)
    
    static private let timeLineAttachmentDurationPattern = "<(\\d+)>"
    static private let timeLineAttachmentDurationRegex = try! NSRegularExpression(pattern: timeLineAttachmentDurationPattern)
    
    public init?(_ description: String) {
        let matchs = LyricsLineAttachmentTimeLine.timeLineAttachmentRegex.matches(in: description)
        attachment = matchs.flatMap { Tag(description[$0.rangeAt(1)]!) }
        guard !attachment.isEmpty else {
            return nil
        }
        if let match = LyricsLineAttachmentTimeLine.timeLineAttachmentDurationRegex.firstMatch(in: description) {
            durationMSec = Int(description[match.rangeAt(1)]!)
        }
    }
}

extension LyricsLineAttachmentTimeLine.Tag: LosslessStringConvertible {
    
    public var description: String {
        return "<\(timeTagMSec),\(index)>"
    }
    
    public init?(_ description: String) {
        let components = description.components(separatedBy: ",")
        guard components.count == 2,
            let msec = Int(components[0]),
            let index = Int(components[1]) else {
                return nil
        }
        self.timeTag = TimeInterval(msec) / 1000
        self.index = index
    }
}
