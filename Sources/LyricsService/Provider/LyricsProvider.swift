//
//  LyricsServices.swift
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
import LyricsCore
import CXShim

let sharedURLSession = URLSession(configuration: .ephemeral)

public enum LyricsProviders {}

protocol LyricsProvider {
    
    init()
    
    func lyricsPublisher(request: LyricsSearchRequest) -> AnyPublisher<Lyrics, Never>
}

protocol _LyricsProvider: LyricsProvider {
    
    associatedtype LyricsToken
    
    func lyricsSearchPublisher(request: LyricsSearchRequest) -> AnyPublisher<LyricsToken, Never>
    
    func lyricsFetchPublisher(token: LyricsToken) -> AnyPublisher<Lyrics, Never>
}

extension _LyricsProvider {
    
    public func lyricsPublisher(request: LyricsSearchRequest) -> AnyPublisher<Lyrics, Never> {
        return lyricsSearchPublisher(request: request)
            .prefix(request.limit)
            .flatMap(self.lyricsFetchPublisher)
            .map { lrc in
                lrc.metadata.request = request
                // TODO: lrc.metadata.searchIndex
                return lrc
            }.eraseToAnyPublisher()
    }
}
