//
//  Dictionary+HttpParameter.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
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
