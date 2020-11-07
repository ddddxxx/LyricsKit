//
//  Group.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LyricsCore
import CXShim

extension LyricsProviders {
    
    public final class Group: LyricsProvider {
        
        var providers: [LyricsProvider]
        
        public init(service: [LyricsProviders.Service] = LyricsProviders.Service.allCases) {
            providers = service.map { $0.create() }
        }
        
        public func lyricsPublisher(request: LyricsSearchRequest) -> AnyPublisher<Lyrics, Never> {
            return providers.cx.publisher
                .flatMap { $0.lyricsPublisher(request: request) }
                .eraseToAnyPublisher()
        }
    }
}
