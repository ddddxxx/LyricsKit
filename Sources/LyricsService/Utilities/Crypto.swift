//
//  CommonCrypto+Extension.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation
import CommonCrypto

func md5(_ string: String) -> Data {
    let messageData = string.data(using:.utf8)!
    var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
    digestData.withUnsafeMutableBytes { digestBytes in
        let digestBytes = digestBytes.bindMemory(to: UInt8.self)
        messageData.withUnsafeBytes { messageBytes in
            _ = CC_MD5(messageBytes.baseAddress, CC_LONG(messageBytes.count), digestBytes.baseAddress)
        }
    }
    return digestData
}
