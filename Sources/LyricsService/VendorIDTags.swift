//
//  VendorIDTags.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

extension Lyrics.IDTagKey {
    
    /// QQMusic has their Furigana annotations. Like this:
    ///
    ///     [kana:11111111111111111あお1うみ1か1なた1いま...]
    ///
    /// It seems just put all kana together with `1` as separator. But we don't
    /// need it anyway, as we can `generateFurigana()` ourself.
    static let qqMusicKana = Lyrics.IDTagKey("kana")
}
