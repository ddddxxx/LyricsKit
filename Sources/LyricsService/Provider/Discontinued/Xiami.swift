//
//  LyricsXiami.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LyricsCore
import CXShim
import CXExtensions

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private let xiamiSearchBaseURLString = "http://api.xiami.com/web?"

extension LyricsProviders {
    public final class Xiami {
        public init() {}
    }
}

extension LyricsProviders.Xiami: _LyricsProvider {
    
    public struct LyricsToken {
        let value: XiamiResponseSearchResult.Data.Song
    }
    
    public static let service: LyricsProviders.Service? = nil
    
    public func lyricsSearchPublisher(request: LyricsSearchRequest) -> AnyPublisher<LyricsToken, Never> {
        let parameter: [String : Any] = [
            "key": request.searchTerm.description,
            "limit": 10,
            "r": "search/songs",
            "v": "2.0",
            "app_key": 1,
        ]
        let url = URL(string: xiamiSearchBaseURLString + parameter.stringFromHttpParameters)!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("http://h.xiami.com/", forHTTPHeaderField: "Referer")
        return sharedURLSession.cx.dataTaskPublisher(for: req)
            .map(\.data)
            .decode(type: XiamiResponseSearchResult.self, decoder: JSONDecoder().cx)
            .map(\.data.songs)
            .replaceError(with: [])
            .flatMap(Publishers.Sequence.init)
            .map(LyricsToken.init)
            .eraseToAnyPublisher()
    }
    
    public func lyricsFetchPublisher(token: LyricsToken) -> AnyPublisher<Lyrics, Never> {
        guard let lrcURLStr = token.value.lyric,
            let lrcURL = URL(string: lrcURLStr) else {
                return Empty().eraseToAnyPublisher()
        }
        return sharedURLSession.cx.dataTaskPublisher(for: lrcURL)
            .compactMap {
                guard let lrcStr = String(data: $0.data, encoding: .utf8),
                    let lrc = Lyrics(ttpodXtrcContent:lrcStr) else {
                        return nil
                }
                lrc.idTags[.title] = token.value.song_name
                lrc.idTags[.artist] = token.value.artist_name
                
                lrc.metadata.remoteURL = lrcURL
                lrc.metadata.artworkURL = token.value.album_logo
                lrc.metadata.serviceToken = token.value.lyric
                return lrc
            }.ignoreError()
            .eraseToAnyPublisher()
    }
}
