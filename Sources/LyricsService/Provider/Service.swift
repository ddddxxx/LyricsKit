//
//  Service.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension LyricsProviders {
    
    public enum Service: String, CaseIterable {
        case netease = "163"
        case qq = "QQMusic"
        case kugou = "Kugou"
        case gecimi = "Gecimi"
        case syair = "Syair"
    }
}

extension LyricsProviders.Service {
    
    func create() -> LyricsProvider {
        switch self {
        case .netease:  return LyricsProviders.NetEase()
        case .qq:       return LyricsProviders.QQMusic()
        case .kugou:    return LyricsProviders.Kugou()
        case .gecimi:   return LyricsProviders.Gecimi()
        #if canImport(Darwin)
        case .syair:    return LyricsProviders.Syair()
        #endif
        default:        return LyricsProviders.Unsupported()
        }
    }
}
