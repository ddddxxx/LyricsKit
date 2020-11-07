//
//  QQResponseSingleLyrics.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

struct QQResponseSingleLyrics: Decodable {
    let retcode: Int
    let code: Int
    let subcode: Int
    let lyric: Data
    let trans: Data?
}

extension QQResponseSingleLyrics {
    
    var lyricString: String? {
        return String(data: lyric, encoding: .utf8)?.decodingXMLEntities()
    }
    
    var transString: String? {
        guard let data = trans,
            let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string.decodingXMLEntities()
    }
}
