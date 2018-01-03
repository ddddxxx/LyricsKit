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
        let lineMatchs = ttpodXtrcLineRegex.matches(in: content)
        guard !lineMatchs.filter({$0[2] != nil}).isEmpty else {
            self.init(content)
            return
        }
        self.init()
        id3TagRegex.matches(in: content).forEach { match in
            if let key = match[1]?.content.trimmingCharacters(in: .whitespaces),
                let value = match[2]?.content.trimmingCharacters(in: .whitespaces),
                !key.isEmpty,
                !value.isEmpty {
                idTags[.init(key)] = value
            }
        }
        
        lines = lineMatchs.flatMap { match -> [LyricsLine] in
            let timeTagStr = String(match[1]!.content)
            let timeTags = resolveTimeTag(timeTagStr)
            
            var lineContent = ""
            var timetagAttachment = LyricsLineAttachmentTimeLine(tags: [.init(timeTag: 0, index: 0)])
            var dt = 0.0
            ttpodXtrcInlineTagRegex.matches(in: content, range: match[2]!.range).forEach { m in
                let timeTagStr = m[1]!.content
                let timeTag = TimeInterval(timeTagStr)! / 1000
                let fragment = m[2]!.content
                lineContent += fragment
                dt += timeTag
                timetagAttachment.tags.append(.init(timeTag: dt, index: lineContent.count))
            }
            
            var line = LyricsLine(content: lineContent, position: 0, attachments: [.timetag: timetagAttachment])
            
            if let translationStr = match[3]?.string {
                let translationAttachment = LyricsLineAttachmentPlainText(translationStr)
                line.attachments[.translation] = translationAttachment
                metadata.attachmentTags.insert(.translation)
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
        metadata.attachmentTags.insert(.timetag)
        
        guard !lines.isEmpty else {
            return nil
        }
    }
}
