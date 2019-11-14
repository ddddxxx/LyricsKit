//
//  QQResponseSingleLyrics.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
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
