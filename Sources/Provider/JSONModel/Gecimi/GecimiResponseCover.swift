//
//  GecimiResponseCover.swift
//  LyricsProvider
//
//  Created by 邓翔 on 2017/9/14.
//

import Foundation

struct GecimiResponseCover: Decodable {
    let result: Result
    
    /*
    let count: Int
    let code: Int
     */
    
    struct Result: Decodable {
        let cover: URL
        let thumb: URL
    }
}
