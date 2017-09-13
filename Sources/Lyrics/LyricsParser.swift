//
//  LyricsParser.swift
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

private let lyricsLineAttachmentPattern = "^((?:\\[[-+]?\\d+:\\d+(?:.\\d+)?\\])+)\\[(.+?)\\](.*)$"
private let lyricsLineAttachmentRegex = try! NSRegularExpression(pattern: lyricsLineAttachmentPattern)
func resolveLyricsLineAttachment(_ str: String) -> [(TimeInterval, LyricsLineAttachmentTag, LyricsLineAttachment)]? {
    guard let match = lyricsLineAttachmentRegex.firstMatch(in: str) else {
        return nil
    }
    let timeTagStr = str[match.rangeAt(1)]!
    let timeTags = resolveTimeTag(timeTagStr)
    
    let attachmentTagStr = str[match.rangeAt(2)]!
    let attachmentTag = LyricsLineAttachmentTag(attachmentTagStr)
    
    let attachmentStr = str[match.rangeAt(3)] ?? ""
    guard let attachment = LyricsLineAttachmentFactory.createAttachment(str: attachmentStr, tag: attachmentTag) else {
        return nil
    }
    
    return timeTags.map { ($0, attachmentTag, attachment) }
}

private let lyricsLinePattern = "^(\\[[-+]?\\d+:\\d+(?:.\\d+)?\\])+([^【]*)(?:【(.*)】)?$"
private let lyricsLineRegex = try! NSRegularExpression(pattern: lyricsLinePattern)
func resolveLyricsLine(_ str: String) -> [LyricsLine]? {
    guard let match = lyricsLineRegex.firstMatch(in: str) else {
        return nil
    }
    let timeTagStr = str[match.rangeAt(1)]!
    let timeTags = resolveTimeTag(timeTagStr)
    
    let lyricsContentStr = str[match.rangeAt(2)]!
    var line = LyricsLine(content: lyricsContentStr, position: 0)
    
    if let translationStr = str[match.rangeAt(3)] {
        let translationAttachment = LyricsLineAttachmentPlainText(translationStr)
        line.attachments[.translation] = translationAttachment
    }
    
    return timeTags.map { timeTag in
        var l = line
        l.position = timeTag
        return l
    }
}

private let id3TagPattern = "^\\[(.+):(.*)\\]$"
private let id3TagRegex = try! NSRegularExpression(pattern: id3TagPattern)
func resolveID3Tag(_ str: String) -> (Lyrics.IDTagKey, String)? {
    guard let match = id3TagRegex.firstMatch(in: str),
        let key = str[match.rangeAt(1)]?.trimmingCharacters(in: .whitespaces),
        let value = str[match.rangeAt(2)]?.trimmingCharacters(in: .whitespaces) else {
            return nil
    }
    let k = Lyrics.IDTagKey(key)
    return (k, value)
}

private let timeTagPattern = "\\[([-+]?\\d+):(\\d+(?:.\\d+)?)\\]"
private let timeTagRegex = try! NSRegularExpression(pattern: timeTagPattern)
fileprivate func resolveTimeTag(_ str: String) -> [TimeInterval] {
    let matchs = timeTagRegex.matches(in: str)
    return matchs.map { match in
        let min = Double(str[match.rangeAt(1)]!)!
        let sec = Double(str[match.rangeAt(2)]!)!
        return min * 60 + sec
    }
}

// MARK: -

extension NSRegularExpression {
    
    func matches(in string: String, options: NSRegularExpression.MatchingOptions = []) -> [NSTextCheckingResult] {
        let r = NSRange(string.startIndex..<string.endIndex, in: string)
        return matches(in: string, options: options, range: r)
    }
    
    func firstMatch(in string: String, options: NSRegularExpression.MatchingOptions = []) -> NSTextCheckingResult? {
        let r = NSRange(string.startIndex..<string.endIndex, in: string)
        return firstMatch(in: string, options: options, range: r)
    }
}

extension String {
    
    subscript(nsRange: NSRange) -> String? {
        guard let r = Range(nsRange, in: self) else {
            return nil
        }
        return String(self[r])
    }
}
