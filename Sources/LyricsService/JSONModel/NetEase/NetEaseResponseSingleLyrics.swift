//
//  NetEaseResponseSingleLyrics.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
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
