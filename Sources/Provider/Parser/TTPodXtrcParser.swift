//
//  TTPodXtrcParser.swift
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
    
    convenience init?(ttpodXtrcContent content: String) {
        self.init()
        id3TagRegex.matches(in: content).forEach { match in
            if let key = content[match.range(at: 1)]?.trimmingCharacters(in: .whitespaces),
                let value = content[match.range(at: 2)]?.trimmingCharacters(in: .whitespaces),
                !key.isEmpty,
                !value.isEmpty {
                idTags[.init(key)] = value
            }
        }
        
        lines = ttpodXtrcLineRegex.matches(in: content).flatMap { match -> [LyricsLine] in
            let timeTagStr = content[match.range(at: 1)]!
            let timeTags = resolveTimeTag(timeTagStr)
            
            var lineContent = ""
            var timetagAttachment = LyricsLineAttachmentTimeLine(tags: [.init(timeTag: 0, index: 0)])
            var dt = 0.0
            ttpodXtrcInlineTagRegex.matches(in: content, range: match.range(at: 2)).forEach { m in
                let timeTagStr = content[m.range(at: 1)]!
                let timeTag = TimeInterval(timeTagStr)! / 1000
                let fragment = content[m.range(at: 2)]!
                lineContent += fragment
                dt += timeTag
                timetagAttachment.tags.append(.init(timeTag: dt, index: lineContent.count))
            }
            
            var line = LyricsLine(content: lineContent, position: 0, attachments: [.timetag: timetagAttachment])
            
            if let translationStr = content[match.range(at: 3)] {
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
        
        guard !lines.isEmpty else {
            return nil
        }
    }
}
