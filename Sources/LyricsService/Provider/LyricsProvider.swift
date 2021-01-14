//
//  LyricsProvider.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LyricsCore
import CXShim

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

let sharedURLSession = URLSession(configuration: .ephemeral)

public enum LyricsProviders {}

protocol LyricsProvider {
    
    func lyricsPublisher(request: LyricsSearchRequest) -> AnyPublisher<Lyrics, Never>
}

protocol _LyricsProvider: LyricsProvider {
    
    associatedtype LyricsToken
    
    static var service: LyricsProviders.Service { get }
    
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
                lrc.metadata.service = Self.service
                // TODO: lrc.metadata.searchIndex
                return lrc
            }.eraseToAnyPublisher()
    }
}
