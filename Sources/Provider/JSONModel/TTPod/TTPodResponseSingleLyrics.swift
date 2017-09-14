//
//  TTPodResponseSingleLyrics.swift
//  LyricsProvider
//
//  Created by 邓翔 on 2017/9/14.
//

import Foundation

struct TTPodResponseSingleLyrics: Decodable {
    let data: Data
    let code: Int
    
    struct Data: Decodable {
        let lrc: String
    }
}
