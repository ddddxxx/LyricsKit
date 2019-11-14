//
//  KugouResponseSearchResult.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
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
