//
//  LyricsServices.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
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
