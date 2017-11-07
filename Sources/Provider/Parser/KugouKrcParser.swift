//
//  KugouKrcParser.swift
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
    
    convenience init?(kugouKrcContent content: String) {
        self.init()
        var languageHeader: KugouKrcHeaderFieldLanguage?
        id3TagRegex.matches(in: content).forEach { match in
            guard let key = content[match.range(at: 1)]?.trimmingCharacters(in: .whitespaces),
                let value = content[match.range(at: 2)]?.trimmingCharacters(in: .whitespaces),
                !key.isEmpty,
                !value.isEmpty else {
                    return
            }
            if key == "language" {
                if let data = Data(base64Encoded: value) {
                    // TODO: error handler
                    languageHeader = try? JSONDecoder().decode(KugouKrcHeaderFieldLanguage.self, from: data)
                }
            } else {
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
            kugouInlineTagRegex.matches(in: content, range: match.range(at: 3)).forEach { m in
                let t1 = Int(content[m.range(at: 1)]!)!
                let t2 = Int(content[m.range(at: 2)]!)!
                let t = TimeInterval(t1 + t2) / 1000
                let fragment = content[m.range(at: 3)]!
                lineContent += fragment
                attachment.tags.append(.init(timeTag: t, index: lineContent.count))
            }
            
            var line = LyricsLine(content: lineContent, position: timeTag, attachments: [.timetag: attachment])
            line.lyrics = self
            return line
        }
        metadata.attachmentTags.insert(.timetag)
        
        // TODO: multiple translation
        if let transContent = languageHeader?.content.first?.lyricContent {
            transContent.prefix(lines.count).enumerated().forEach { index, item in
                if let str = item.first {
                    lines[index].attachments[.translation] = LyricsLineAttachmentPlainText(str)
                }
            }
            metadata.attachmentTags.insert(.translation)
        }
        
        guard !lines.isEmpty else {
            return nil
        }
    }
}
