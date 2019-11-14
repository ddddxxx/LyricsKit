//
//  LyricsMetadata.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation

extension Lyrics.MetaData.Key {
    public static var attachmentTags = Lyrics.MetaData.Key("attachmentTags")
}

extension Lyrics.MetaData {
    
    public var attachmentTags: Set<LyricsLine.Attachments.Tag> {
        get { return data[.attachmentTags] as? Set<LyricsLine.Attachments.Tag> ?? [] }
        set { data[.attachmentTags] = newValue }
    }
    
    public var hasTranslation: Bool {
        return attachmentTags.contains { tag in
            tag.isTranslation
        }
    }
}
