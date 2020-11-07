//
//  KugouResponseSingleLyrics.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

struct KugouResponseSingleLyrics: Decodable {
    let content: Data
    let fmt: Format
    
    /*
    let info: String
    let status: Int
    let charset: String
     */
    
    enum Format: String, Decodable {
        case lrc, krc
    }
}
