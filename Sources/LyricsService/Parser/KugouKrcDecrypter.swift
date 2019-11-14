//
//  KugouKrcDecrypter.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation
import Gzip

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
