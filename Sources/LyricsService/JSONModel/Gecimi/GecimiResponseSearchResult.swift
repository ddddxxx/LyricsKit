//
//  GecimiResponseSearchResult.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation

struct GecimiResponseSearchResult: Decodable {
    let result: [Result]
    
    /*
    let count: Int
    let code: Int
     */
    
    struct Result: Decodable {
        let lrc: URL
        let aid: Int
        
        /*
        let sid: Int
        let artist_id: Int
        let song: String
         */
    }
}
