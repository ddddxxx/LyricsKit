//
//  ViewLyricsResponseSearchResult.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation

struct ViewLyricsResponseSearchResult: Decodable {
    
    let link: String
    let artist: String
    let title: String
    let album: String
    let uploader: String?
    let timelength: Int?
    let rate: Double?
    let ratecount: Int?
    let downloads: Int?
}
