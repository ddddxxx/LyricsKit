//
//  LyricsParser.swift
//  LyricsProvider
//
//  Created by 邓翔 on 2017/9/11.
//

import Foundation

let lyricsLineAttachmentPattern = "^((?:\\[[-+]?\\d+:\\d+(?:.\\d+)?\\])+)\\[(.+?)\\](.*)$"
let lyricsLineAttachmentRegex = try! NSRegularExpression(pattern: lyricsLineAttachmentPattern)
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

let lyricsLinePattern = "^(\\[[-+]?\\d+:\\d+(?:.\\d+)?\\])+([^【]*)(?:【(.*)】)?$"
let lyricsLineRegex = try! NSRegularExpression(pattern: lyricsLinePattern)
func resolveLyricsLine(_ str: String) -> [LyricsLine]? {
    guard let match = lyricsLineRegex.firstMatch(in: str) else {
        return nil
    }
    let timeTagStr = str[match.rangeAt(1)]!
    let timeTags = resolveTimeTag(timeTagStr)
    
    let lyricsContentStr = str[match.rangeAt(2)]!
    var line = LyricsLine(content: lyricsContentStr, position: 0)
    
    if let translationStr = str[match.rangeAt(3)] {
        let translationAttachment = LyricsLineAttachmentPlainText(string: translationStr)
        line.attachment[.translation] = translationAttachment
    }
    
    return timeTags.map { timeTag in
        var l = line
        l.position = timeTag
        return l
    }
}

let id3TagPattern = "^\\[(.+):(.*)\\]$"
let id3TagRegex = try! NSRegularExpression(pattern: id3TagPattern)
func resolveID3Tag(_ str: String) -> (String, String)? {
    guard let match = id3TagRegex.firstMatch(in: str),
        let key = str[match.rangeAt(1)]?.trimmingCharacters(in: .whitespaces),
        let value = str[match.rangeAt(2)]?.trimmingCharacters(in: .whitespaces) else {
            return nil
    }
    return (key, value)
}

let timeTagPattern = "\\[([-+]?\\d+):(\\d+(?:.\\d+)?)\\]"
let timeTagRegex = try! NSRegularExpression(pattern: timeTagPattern)
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
