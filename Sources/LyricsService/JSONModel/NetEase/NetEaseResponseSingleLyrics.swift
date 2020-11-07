//
//  NetEaseResponseSingleLyrics.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

struct NetEaseResponseSingleLyrics: Decodable {
    let lrc: Lyric?
    let klyric: Lyric?
    let tlyric: Lyric?
    let lyricUser: User?
    
    /*
    let sgc: Bool
    let sfy: Bool
    let qfy: Bool
    let code: Int
    let transUser: User
     */
    
    struct User: Decodable {
        let nickname: String
        
        /*
        let id: Int
        let status: Int
        let demand: Int
        let userid: Int
        let uptime: Int
         */
    }
    
    struct Lyric: Decodable {
        let lyric: String?
        
        /*
        let version: Int
         */
    }
}
