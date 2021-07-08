//
//  KugouKrcDecrypter.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import Gzip

private let decodeKey: [UInt8] = [64, 71, 97, 119, 94, 50, 116, 71, 81, 54, 49, 45, 206, 210, 110, 105]
private let flagKey = "krc1".data(using: .ascii)!

func decryptKugouKrc(_ data: Data) -> String? {
    guard data.starts(with: flagKey) else {
        return nil
    }
    
    let decrypted = data.dropFirst(4).enumerated().map { index, byte in
        return byte ^ decodeKey[index & 0b1111]
    }
    
    guard let unarchivedData = try? Data(decrypted).gunzipped() else {
        return nil
    }
    
    return String(bytes: unarchivedData, encoding: .utf8)
}
