//
//  KugouResponseSearchResult.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

struct KugouResponseSearchResult: Decodable {
    let candidates: [Item]
    
    /*
    let info: String
    let status: Int
    let proposal: String
    let keyword: String
     */
    
    struct Item: Decodable {
        let id: String
        let accesskey: String
        let song: String
        let singer: String
        let duration: Int // in msec
        
        /*
        let adjust: Int
        let hitlayer: Int
        let krctype: Int
        let language: String
        let nickname: String
        let originame: String
        let origiuid: String
        let score: Int
        let soundname: String
        let sounduid: String
        let transname: String
        let transuid: String
        let uid: String
         */
        
        // let parinfo: [Any]
    }
}
