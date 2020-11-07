//
//  NetEaseKLyricParser.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LyricsCore

extension Lyrics {
    
    convenience init?(netEaseKLyricContent content: String) {
        self.init()
        id3TagRegex.matches(in: content).forEach { match in
            if let key = match[1]?.string.trimmingCharacters(in: .whitespaces),
                let value = match[2]?.string.trimmingCharacters(in: .whitespaces),
                !key.isEmpty,
                !value.isEmpty {
                idTags[.init(key)] = value
            }
        }
        
        lines = krcLineRegex.matches(in: content).map { match in
            let timeTagStr = match[1]!.string
            let timeTag = TimeInterval(timeTagStr)! / 1000
            
            let durationStr = match[2]!.string
            let duration = TimeInterval(durationStr)! / 1000
            
            var lineContent = ""
            var attachment = LyricsLine.Attachments.WordTimeTag(tags: [.init(timeTag: 0, index: 0)], duration: duration)
            var dt = 0.0
            netEaseInlineTagRegex.matches(in: content, range: match[3]!.range).forEach { m in
                let timeTagStr = m[1]!.string
                var timeTag = TimeInterval(timeTagStr)! / 1000
                var fragment = m[2]!.string
                if m[3] != nil {
                    timeTag += 0.001
                    fragment += " "
                }
                lineContent += fragment
                dt += timeTag
                attachment.tags.append(.init(timeTag: dt, index: lineContent.count))
            }
            
            let att = LyricsLine.Attachments(attachments: [.timetag: attachment])
            var line = LyricsLine(content: lineContent, position: timeTag, attachments: att)
            line.lyrics = self
            return line
        }
        metadata.attachmentTags.insert(.timetag)
        
        guard !lines.isEmpty else {
            return nil
        }
    }
}
