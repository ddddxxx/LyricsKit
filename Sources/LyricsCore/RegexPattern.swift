//
//  RegexPattern.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
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
import Regex

private let timeTagPattern = "\\[([-+]?\\d+):(\\d+(?:\\.\\d+)?)\\]"
private let timeTagRegex = try! Regex(timeTagPattern)
func resolveTimeTag(_ str: String) -> [TimeInterval] {
    let matchs = timeTagRegex.matches(in: str)
    return matchs.map { match in
        let min = Double(match[1]!.content)!
        let sec = Double(match[2]!.content)!
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
