//
//  TTPodXtrcParser.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LyricsCore

extension Lyrics {
    
    convenience init?(ttpodXtrcContent content: String) {
        let lineMatchs = ttpodXtrcLineRegex.matches(in: content)
        guard !lineMatchs.filter({$0[2] != nil || $0[3] != nil}).isEmpty else {
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
            let timeTagStr = match[1]!.string
            let timeTags = resolveTimeTag(timeTagStr)
            
            var line: LyricsLine
            if let plainText = match[3]?.string {
                line = LyricsLine(content: plainText, position: 0)
            } else {
                var lineContent = ""
                var timetagAttachment = LyricsLine.Attachments.WordTimeTag(tags: [.init(timeTag: 0, index: 0)])
                var dt = 0.0
                ttpodXtrcInlineTagRegex.matches(in: content, range: match[2]!.range).forEach { m in
                    let timeTagStr = m[1]!.content
                    let timeTag = TimeInterval(timeTagStr)! / 1000
                    let fragment = m[2]!.content
                    guard !fragment.isEmpty else { return }
                    lineContent += fragment
                    dt += timeTag
                    timetagAttachment.tags.append(.init(timeTag: dt, index: lineContent.count))
                }
                
                let att = LyricsLine.Attachments(attachments: [.timetag: timetagAttachment])
                line = LyricsLine(content: lineContent, position: 0, attachments: att)
            }
            
            if let translationStr = match[4]?.string, !translationStr.isEmpty {
                line.attachments[.translation()] = translationStr
                metadata.attachmentTags.insert(.translation())
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
