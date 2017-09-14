//
//  QQResponseSingleLyrics.swift
//  LyricsProvider
//
//  Created by 邓翔 on 2017/9/13.
//

import Foundation

struct QQResponseSingleLyrics: Decodable {
    let retcode: Int
    let code: Int
    let subcode: Int
    let lyric: Data // base64 encoded
    let trans: Data? // base64 encoded
}
