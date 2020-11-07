//
//  RegexPattern.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Regex

private let timeTagPattern = "\\[([-+]?\\d+):(\\d+(?:\\.\\d+)?)\\]"
private let timeTagRegex = try! Regex(timeTagPattern)
func resolveTimeTag(_ str: String) -> [TimeInterval] {
    let matchs = timeTagRegex.matches(in: str)
    return matchs.map { match in
        let min = Double(match[1]!.string)!
        let sec = Double(match[2]!.string)!
        return min * 60 + sec
    }
}

private let id3TagPattern = "^(?!\\[[+-]?\\d+:\\d+(?:\\.\\d+)?\\])\\[(.+?):(.+)\\]$"
let id3TagRegex = try! Regex(id3TagPattern, options: .anchorsMatchLines)

private let lyricsLinePattern = "^(\\[[+-]?\\d+:\\d+(?:\\.\\d+)?\\])+(?!\\[)([^【\\n\\r]*)(?:【(.*)】)?"
let lyricsLineRegex = try! Regex(lyricsLinePattern, options: .anchorsMatchLines)

private let base60TimePattern = "^\\s*(?:(\\d+):)?(\\d+(?:.\\d+)?)\\s*$"
let base60TimeRegex = try! Regex(base60TimePattern)

private let lyricsLineAttachmentPattern = "^(\\[[+-]?\\d+:\\d+(?:\\.\\d+)?\\])+\\[(.+?)\\](.*)"
let lyricsLineAttachmentRegex = try! Regex(lyricsLineAttachmentPattern, options: .anchorsMatchLines)

private let timeLineAttachmentPattern = "<(\\d+,\\d+)>"
let timeLineAttachmentRegex = try! Regex(timeLineAttachmentPattern)

private let timeLineAttachmentDurationPattern = "<(\\d+)>"
let timeLineAttachmentDurationRegex = try! Regex(timeLineAttachmentDurationPattern)

private let rangeAttachmentPattern = "<([^,]+,\\d+,\\d+)>"
let rangeAttachmentRegex = try! Regex(rangeAttachmentPattern)
