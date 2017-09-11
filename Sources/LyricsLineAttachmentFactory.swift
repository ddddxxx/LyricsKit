//
//  LyricsLineAttachmentFactory.swift
//  LyricsProvider
//
//  Created by 邓翔 on 2017/9/11.
//

import Foundation

enum LyricsLineAttachmentFactory {
    
    static func createAttachment(str: String, tag: LyricsLineAttachmentTag) -> LyricsLineAttachment? {
        switch tag {
        case .timetag:
            return LyricsLineAttachmentTimeLine(string: str)
        case .furigana, .romaji:
            return LyricsLineAttachmentRangeBased(string: str)
        default:
            return LyricsLineAttachmentPlainText(string: str)
        }
    }
}
