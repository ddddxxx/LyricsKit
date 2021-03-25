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

let krcLineRegex = Regex(#"^\[(\d+),(\d+)\](.*)"#, options: .anchorsMatchLines)

let netEaseInlineTagRegex = Regex(#"\(0,(\d+)\)([^(]+)(\(0,1\) )?"#)

let kugouInlineTagRegex = Regex(#"<(\d+),(\d+),0>([^<]*)"#)

let ttpodXtrcLineRegex = Regex(
    #"^((?:\[[+-]?\d+:\d+(?:\.\d+)?\])+)(?:((?:<\d+>[^<\r\n]+)+)|(.*))$(?:[\r\n]+\[x\-trans\](.*))?"#,
    options: .anchorsMatchLines)

let ttpodXtrcInlineTagRegex = Regex(#"<(\d+)>([^<\r\n]*)"#)

let syairSearchResultRegex = Regex(#"<div class="title"><a href="([^"]+)">"#)

let syairLyricsContentRegex = Regex(#"<div class="entry">(.+?)<div"#, options: .dotMatchesLineSeparators)
