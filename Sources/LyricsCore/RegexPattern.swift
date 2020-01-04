//
//  RegexPattern.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
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
