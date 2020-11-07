//
//  ViewLyricsResponseSearchResult.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
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
