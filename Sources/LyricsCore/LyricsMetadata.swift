//
//  LyricsMetadata.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
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
        return attachmentTags.contains(where: \.isTranslation)
    }
}
