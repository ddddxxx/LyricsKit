//
//  GecimiResponseCover.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
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
