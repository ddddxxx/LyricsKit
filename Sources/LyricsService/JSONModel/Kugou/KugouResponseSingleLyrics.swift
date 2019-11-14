//
//  KugouResponseSingleLyrics.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
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
