//
//  RegexPattern.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import Regex

private let timeTagRegex = Regex(#"\[([-+]?\d+):(\d+(?:\.\d+)?)\]"#)
func resolveTimeTag(_ str: String) -> [TimeInterval] {
    let matchs = timeTagRegex.matches(in: str)
    return matchs.map { match in
        let min = Double(match[1]!.content)!
        let sec = Double(match[2]!.content)!
        return min * 60 + sec
    }
}

let id3TagRegex = Regex(#"^(?!\[[+-]?\d+:\d+(?:\.\d+)?\])\[(.+?):(.+)\]$"#, options: .anchorsMatchLines)

let lyricsLineRegex = Regex(#"^((?:\[[+-]?\d+:\d+(?:\.\d+)?\])+)(?!\[)([^【\n\r]*)(?:【(.*)】)?"#, options: .anchorsMatchLines)

let base60TimeRegex = Regex(#"^\s*(?:(\d+):)?(\d+(?:.\d+)?)\s*$"#)

let lyricsLineAttachmentRegex = Regex(#"^(\[[+-]?\d+:\d+(?:\.\d+)?\])+\[(.+?)\](.*)"#, options: .anchorsMatchLines)

let timeLineAttachmentRegex = Regex(#"<(\d+,\d+)>"#)

let timeLineAttachmentDurationRegex = Regex(#"<(\d+)>"#)

let rangeAttachmentRegex = Regex(#"<([^,]+,\d+,\d+)>"#)
