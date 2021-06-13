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
        var idTags: [IDTagKey: String] = [:]
        var languageHeader: KugouKrcHeaderFieldLanguage?
        id3TagRegex.matches(in: content).forEach { match in
            guard let key = match[1]?.content.trimmingCharacters(in: .whitespaces),
                let value = match[2]?.content.trimmingCharacters(in: .whitespaces),
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
        
        var lines: [LyricsLine] = krcLineRegex.matches(in: content).map { match in
            let timeTagStr = match[1]!.content
            let timeTag = TimeInterval(timeTagStr)! / 1000
            
            let durationStr = match[2]!.content
            let duration = TimeInterval(durationStr)! / 1000
            
            var lineContent = ""
            var attachment = LyricsLine.Attachments.InlineTimeTag(tags: [.init(index: 0, time: 0)], duration: duration)
            kugouInlineTagRegex.matches(in: content, range: match[3]!.range).forEach { m in
                let t1 = Int(m[1]!.content)!
                let t2 = Int(m[2]!.content)!
                let t = TimeInterval(t1 + t2) / 1000
                let fragment = m[3]!.content
                let prevCount = lineContent.count
                lineContent += fragment
                if lineContent.count > prevCount {
                    attachment.tags.append(.init(index: lineContent.count, time: t))
                }
            }
            
            let att = LyricsLine.Attachments(attachments: [.timetag: attachment])
            return LyricsLine(content: lineContent, position: timeTag, attachments: att)
        }
        guard !lines.isEmpty else {
            return nil
        }
        self.init(lines: lines, idTags: idTags)
        
        // TODO: multiple translation
        if let transContent = languageHeader?.content.first?.lyricContent {
            transContent.prefix(lines.count).enumerated().forEach { index, item in
                guard !item.isEmpty else { return }
                let str = item.joined(separator: " ")
                lines[index].attachments[.translation()] = str
            }
            metadata.attachmentTags.insert(.translation())
        }
    }
}
