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

private let krcLinePattern = "^\\[(\\d+),(\\d+)\\](.*)"
let krcLineRegex = try! Regex(krcLinePattern, options: .anchorsMatchLines)

private let netEaseInlineTagPattern = "\\(0,(\\d+)\\)([^(]+)(\\(0,1\\) )?"
let netEaseInlineTagRegex = try! Regex(netEaseInlineTagPattern)

private let kugouInlineTagPattern = "<(\\d+),(\\d+),0>([^<]*)"
let kugouInlineTagRegex = try! Regex(kugouInlineTagPattern)

private let ttpodXtrcLinePattern = #"^((?:\[[+-]?\d+:\d+(?:\.\d+)?\])+)(?:((?:<\d+>[^<\r\n]+)+)|(.*))$(?:[\r\n]+\[x\-trans\](.*))?"#
let ttpodXtrcLineRegex = try! Regex(ttpodXtrcLinePattern, options: .anchorsMatchLines)

private let ttpodXtrcInlineTagPattern = #"<(\d+)>([^<\r\n]*)"#
let ttpodXtrcInlineTagRegex = try! Regex(ttpodXtrcInlineTagPattern)

private let syairSearchResultPattern = "<div class=\"title\"><a href=\"([^\"]+)\">"
let syairSearchResultRegex = try! Regex(syairSearchResultPattern)

private let syairLyricsContentPattern = "<div class=\"entry\">(.+?)<div"
let syairLyricsContentRegex = try! Regex(syairLyricsContentPattern, options: .dotMatchesLineSeparators)
