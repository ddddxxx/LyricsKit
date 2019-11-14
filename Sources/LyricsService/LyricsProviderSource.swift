//
//  LyricsProviderSource.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation

public enum LyricsProviderSource: String, CaseIterable {
    case netease = "163"
    case qq = "QQMusic"
    case kugou = "Kugou"
    case xiami = "Xiami"
    case gecimi = "Gecimi"
    case viewLyrics = "ViewLyrics"
    case syair = "Syair"
}

extension LyricsProviderSource {
    
    var cls: LyricsProvider.Type {
        switch self {
        case .netease:  return LyricsProviders.NetEase.self
        case .qq:       return LyricsProviders.QQMusic.self
        case .kugou:    return LyricsProviders.Kugou.self
        case .xiami:    return LyricsProviders.Xiami.self
        case .gecimi:   return LyricsProviders.Gecimi.self
        case .viewLyrics: return LyricsProviders.ViewLyrics.self
        case .syair:    return LyricsProviders.Syair.self
        }
    }
}
