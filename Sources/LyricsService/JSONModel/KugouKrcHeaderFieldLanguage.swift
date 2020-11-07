//
//  KugouKrcHeaderFieldLanguage.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

struct KugouKrcHeaderFieldLanguage: Codable {
    let content: [Content]
    let version: Int
    
    struct Content: Codable {
        // TODO: resolve language/type code
        let language: Int
        let type: Int
        let lyricContent: [[String]]
    }
}
