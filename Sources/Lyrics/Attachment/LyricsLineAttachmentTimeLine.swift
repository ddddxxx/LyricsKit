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

private let timeLineAttachmentPattern = "<(\\d+,\\d+)>"
private let timeLineAttachmentRegex = try! Regex(timeLineAttachmentPattern)

private let timeLineAttachmentDurationPattern = "<(\\d+)>"
private let timeLineAttachmentDurationRegex = try! Regex(timeLineAttachmentDurationPattern)

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
    
    public var tags: [Tag]
    public var duration: TimeInterval?
    
    public var durationMSec: Int? {
        get { return duration.map { Int($0 * 1000) } }
        set { duration = newValue.map { TimeInterval($0) / 1000 } }
    }
    
    public var description: String {
        var result = tags.map { $0.description }.joined()
        if let durationMSec = durationMSec {
            result += "<\(durationMSec)>"
        }
        return result
    }
    
    public init(tags: [Tag] = [], duration: TimeInterval? = nil) {
        self.tags = tags
        self.duration = duration
    }
    
    public init?(_ description: String) {
        let matchs = timeLineAttachmentRegex.matches(in: description)
        tags = matchs.flatMap { Tag($0[1]!.string) }
        guard !tags.isEmpty else {
            return nil
        }
        if let match = timeLineAttachmentDurationRegex.firstMatch(in: description) {
            durationMSec = Int(match[1]!.string)
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
