//
//  KugouKrcHeaderFieldLanguage.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
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
