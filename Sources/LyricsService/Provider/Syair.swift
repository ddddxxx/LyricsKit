//
//  Syair.swift
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

#if canImport(Darwin)

private let syairSearchBaseURLString = "https://syair.info/search"
private let syairLyricsBaseURL = URL(string: "https://syair.info")!

extension LyricsProviders {
    public final class Syair {
        public init() {}
    }
}

extension LyricsProviders.Syair: _LyricsProvider {
    
    public static let service: LyricsProviders.Service? = .syair
    
    public func lyricsSearchPublisher(request: LyricsSearchRequest) -> AnyPublisher<String, Never> {
        var parameter: [String: Any] = ["page": 1]
        switch request.searchTerm {
        case let .info(title: title, artist: artist):
            parameter["artist"] = artist
            parameter["title"] = title
        case let .keyword(keyword):
            parameter["q"] = keyword
        }
        let url = URL(string: syairSearchBaseURLString + "?" + parameter.stringFromHttpParameters)!
        return sharedURLSession.cx.dataTaskPublisher(for: url)
            .map {
                return String(data: $0.data, encoding: .utf8).map {
                    return syairSearchResultRegex.matches(in: $0).compactMap { ($0[1]?.string) }
                } ?? []
            }
            .replaceError(with: [])
            .flatMap(Publishers.Sequence.init)
            .eraseToAnyPublisher()
    }
    
    public func lyricsFetchPublisher(token: String) -> AnyPublisher<Lyrics, Never> {
        guard let url = URL(string: token, relativeTo: syairLyricsBaseURL) else {
            return Empty().eraseToAnyPublisher()
        }
        var req = URLRequest(url: url)
        req.addValue("https://syair.info/", forHTTPHeaderField: "Referer")
        return sharedURLSession.cx.dataTaskPublisher(for: req)
            .compactMap {
                guard let str = String(data: $0.data, encoding: .utf8),
                    let lrcData = syairLyricsContentRegex.firstMatch(in: str)?.captures[1]?.string.data(using: .utf8),
                    let lrcStr = try? NSAttributedString(data: lrcData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil).string,
                    let lrc = Lyrics(lrcStr) else {
                        return nil
                }
                lrc.metadata.serviceToken = token
                return lrc
            }.ignoreError()
            .eraseToAnyPublisher()
    }
}

#endif
