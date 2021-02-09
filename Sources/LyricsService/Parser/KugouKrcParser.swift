//
//  KugouKrcParser.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LyricsCore

extension Lyrics {
    
    convenience init?(kugouKrcContent content: String) {
        self.init()
        var languageHeader: KugouKrcHeaderFieldLanguage?
        id3TagRegex.matches(in: content).forEach { match in
            guard let key = match[1]?.string.trimmingCharacters(in: .whitespaces),
                let value = match[2]?.string.trimmingCharacters(in: .whitespaces),
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
            let timeTagStr = match[1]!.string
            let timeTag = TimeInterval(timeTagStr)! / 1000
            
            let durationStr = match[2]!.string
            let duration = TimeInterval(durationStr)! / 1000
            
            var lineContent = ""
            var attachment = LyricsLine.Attachments.WordTimeTag(tags: [.init(timeTag: 0, index: 0)], duration: duration)
            kugouInlineTagRegex.matches(in: content, range: match[3]!.range).forEach { m in
                let t1 = Int(m[1]!.string)!
                let t2 = Int(m[2]!.string)!
                let t = TimeInterval(t1 + t2) / 1000
                let fragment = m[3]!.string
                let prevCount = lineContent.count
                lineContent += fragment
                if lineContent.count > prevCount {
                    attachment.tags.append(.init(timeTag: t, index: lineContent.count))
                }
            }
            
            let att = LyricsLine.Attachments(attachments: [.timetag: attachment])
            var line = LyricsLine(content: lineContent, position: timeTag, attachments: att)
            line.lyrics = self
            return line
        }
        metadata.attachmentTags.insert(.timetag)
        
        // TODO: multiple translation
        if let transContent = languageHeader?.content.first?.lyricContent {
            transContent.prefix(lines.count).enumerated().forEach { index, item in
                guard !item.isEmpty else { return }
                let str = item.joined(separator: " ")
                lines[index].attachments[.translation()] = str
            }
            metadata.attachmentTags.insert(.translation())
        }
        
        guard !lines.isEmpty else {
            return nil
        }
    }
}
