//
//  Dictionary+HttpParameter.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation

extension Dictionary where Key == String {
    
    var stringFromHttpParameters: String {
        let parameterArray = self.map { (key, value) -> String in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
            return escapedKey + "=" + escapedValue
        }
        return parameterArray.joined(separator: "&")
    }
}

extension CharacterSet {
    
    static var uriComponentAllowed: CharacterSet {
        // [-._~0-9a-zA-Z] in RFC 3986
        let unsafe = CharacterSet(charactersIn: "!*'();:&=+$,[]~")
        return CharacterSet.urlHostAllowed.subtracting(unsafe)
    }
}
