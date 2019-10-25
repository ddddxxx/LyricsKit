//
//  LyricsProviderSource.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
