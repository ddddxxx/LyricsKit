//
//  NetEaseKLyricParser.swift
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

extension Lyrics {
    
    convenience init?(netEaseKLyricContent content: String) {
        self.init()
        id3TagRegex.matches(in: content).forEach { match in
            if let key = content[match.range(at: 1)]?.trimmingCharacters(in: .whitespaces),
                let value = content[match.range(at: 2)]?.trimmingCharacters(in: .whitespaces),
                !key.isEmpty,
                !value.isEmpty {
                idTags[.init(key)] = value
            }
        }
        
        lines = krcLineRegex.matches(in: content).map { match in
            let timeTagStr = content[match.range(at: 1)]!
            let timeTag = TimeInterval(timeTagStr)! / 1000
            
            let durationStr = content[match.range(at: 2)]!
            let duration = TimeInterval(durationStr)! / 1000
            
            var lineContent = ""
            var attachment = LyricsLineAttachmentTimeLine(tags: [.init(timeTag: 0, index: 0)], duration: duration)
            var dt = 0.0
            netEaseInlineTagRegex.matches(in: content, range: match.range(at: 3)).forEach { m in
                let timeTagStr = content[m.range(at: 1)]!
                var timeTag = TimeInterval(timeTagStr)! / 1000
                var fragment = content[m.range(at: 2)]!
                if m.range(at: 3).location != NSNotFound {
                    timeTag += 0.001
                    fragment += " "
                }
                lineContent += fragment
                dt += timeTag
                attachment.tags.append(.init(timeTag: dt, index: lineContent.count))
            }
            
            return LyricsLine(content: lineContent, position: timeTag, attachments: [.timetag: attachment])
        }
        
        guard !lines.isEmpty else {
            return nil
        }
    }
}
