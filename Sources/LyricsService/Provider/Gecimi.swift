//
//  Gecimi.swift
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

private let gecimiLyricsBaseURL = URL(string: "http://gecimi.com/api/lyric")!
private let gecimiCoverBaseURL = URL(string:"http://gecimi.com/api/cover")!

extension LyricsProviders {
    public final class Gecimi {
        public init() {}
    }
}

extension LyricsProviders.Gecimi: _LyricsProvider {
    
    public struct LyricsToken {
        let value: GecimiResponseSearchResult.Result
    }
    
    public static let service: LyricsProviders.Service? = .gecimi
    
    public func lyricsSearchPublisher(request: LyricsSearchRequest) -> AnyPublisher<LyricsToken, Never> {
        guard case let .info(title, artist) = request.searchTerm else {
            // cannot search by keyword
            return Empty().eraseToAnyPublisher()
        }
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        let encodedArtist = artist.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        
        let url = gecimiLyricsBaseURL.appendingPathComponent("\(encodedTitle)/\(encodedArtist)")
        let req = URLRequest(url: url)
        
        return sharedURLSession.cx.dataTaskPublisher(for: req)
            .map(\.data)
            .decode(type: GecimiResponseSearchResult.self, decoder: JSONDecoder().cx)
            .map(\.result)
            .replaceError(with: [])
            .flatMap(Publishers.Sequence.init)
            .map(LyricsToken.init)
            .eraseToAnyPublisher()
    }
    
    public func lyricsFetchPublisher(token: LyricsToken) -> AnyPublisher<Lyrics, Never> {
        let token = token.value
        return sharedURLSession.cx.dataTaskPublisher(for: token.lrc)
            .compactMap {
                guard let lrcContent = String(data: $0.data, encoding: .utf8),
                    let lrc = Lyrics(lrcContent) else {
                        return nil
                }
                lrc.metadata.remoteURL = token.lrc
                lrc.metadata.serviceToken = "\(token.aid),\(token.lrc)"
                return lrc
            }.ignoreError()
            .eraseToAnyPublisher()
    }
}
