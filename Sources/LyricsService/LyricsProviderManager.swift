//
//  LyricsProviderManager.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation
import LyricsCore
import CXShim

public final class LyricsProviderManager {
    
    var providers: [LyricsProvider]
    
    public init(sources: [LyricsProviderSource] = LyricsProviderSource.allCases) {
        providers = sources.map { $0.cls.init() }
    }
    
    public func lyricsPublisher(request: LyricsSearchRequest) -> AnyPublisher<Lyrics, Never> {
        return providers.cx.publisher
            .flatMap { $0.lyricsPublisher(request: request) }
            .eraseToAnyPublisher()
    }
}
