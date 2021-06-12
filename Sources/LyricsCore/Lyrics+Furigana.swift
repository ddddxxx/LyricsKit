//
//  Lyrics+Furigana.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if canImport(Darwin)

import Foundation
import SwiftCF

extension Lyrics {
    
    public func generateFurigana() {
        for index in lines.indices {
            lines[index].generateFurigana()
        }
    }
}

private extension LyricsLine {
    
    mutating func generateFurigana() {
        var attachment = LyricsLine.Attachments.RangeAttribute(attributes: [])
        let tokenizer = CFStringTokenizer.create(string: .from(content))
        for tokenType in IteratorSequence(tokenizer) where tokenType.contains(.isCJWordMask) {
            if let (furigana, range) = tokenizer.currentFuriganaAnnotation(in: content) {
                let charRange = content.characterRange(range)
                let attribute = LyricsLine.Attachments.RangeAttribute.Attribute(range: charRange, content: furigana)
                attachment.attributes.append(attribute)
            }
        }
        attachments.furigana = attachment
    }
}

private extension String {
    
    func characterRange(_ range: Range<String.Index>) -> Range<Int> {
        let start = distance(from: startIndex, to: range.lowerBound)
        let length = distance(from: range.lowerBound, to: range.upperBound)
        return start..<(start + length)
    }
    
    func transformLatinToHiragana() -> String? {
        if #available(macOS 10.11, iOS 9.0, tvOS 9.0, watchOS 2.0, *) {
            return applyingTransform(.latinToHiragana, reverse: false)
        }
        let str = CFString.from(self).mutableCopy()
        var range = str.fullRange
        guard CFStringTransform(str, &range, kCFStringTransformLatinHiragana, false) else { return nil }
        return str as String
    }
}

private extension CFStringTokenizer {
    
    func currentFuriganaAnnotation(in string: String) -> (String, Range<String.Index>)? {
        guard let tokenRange = Range(currentTokenRange().asNS, in: string) else {
            return nil
        }
        let tokenStr = string[tokenRange]
        guard tokenStr.unicodeScalars.contains(where: CharacterSet.kanji.contains),
              let latin: String = currentTokenAttribute(.latinTranscription)?.asSwift(),
            let hiragana = latin.transformLatinToHiragana(),
            let (rangeToAnnotate, rangeInAnnotation) = rangeOfUncommonContent(tokenStr, hiragana) else {
                return nil
        }
        let annotation = String(hiragana[rangeInAnnotation])
        return (annotation, rangeToAnnotate)
    }
}

private extension CharacterSet {
    
    static let hiragana = CharacterSet(charactersIn: "\u{3040}"..<"\u{30a0}")
    static let katakana = CharacterSet(charactersIn: "\u{30a0}"..<"\u{3100}")
    static let kana = CharacterSet(charactersIn: "\u{3040}"..<"\u{3100}")
    static let kanji = CharacterSet(charactersIn: "\u{4e00}"..<"\u{9fc0}")
}

private func rangeOfUncommonContent<S1: StringProtocol, S2: StringProtocol>(_ s1: S1, _ s2: S2) -> (Range<String.Index>, Range<String.Index>)? {
    guard s1 != s2, !s1.isEmpty, !s2.isEmpty else {
        return nil
    }
    var (l1, l2) = (s1.startIndex, s2.startIndex)
    while s1[l1] == s2[l2] {
        guard let nl1 = s1.index(l1, offsetBy: 1, limitedBy: s1.endIndex),
            let nl2 = s2.index(l2, offsetBy: 1, limitedBy: s2.endIndex) else {
                break
        }
        (l1, l2) = (nl1, nl2)
    }
    
    var (r1, r2) = (s1.endIndex, s2.endIndex)
    repeat {
        guard let nr1 = s1.index(r1, offsetBy: -1, limitedBy: s1.startIndex),
            let nr2 = s2.index(r2, offsetBy: -1, limitedBy: s2.startIndex) else {
                break
        }
        (r1, r2) = (nr1, nr2)
    } while s1[r1] == s2[r2]
    
    let range1 = (l1...r1).relative(to: s1.indices)
    let range2 = (l2...r2).relative(to: s2.indices)
    return (range1, range2)
}

#endif
