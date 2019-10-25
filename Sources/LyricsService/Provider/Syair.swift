//
//  LyricsSyair.swift
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

private let syairSearchBaseURLString = "https://syair.info/search"
private let syairLyricsBaseURL = URL(string: "https://syair.info")!

extension LyricsProviders {
    public final class Syair {}
}

extension LyricsProviders.Syair: _LyricsProvider {
    
    public static let source: LyricsProviderSource = .syair
    
    func lyricsSearchPublisher(request: LyricsSearchRequest) -> AnyPublisher<String, Never> {
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
                    return syairSearchResultRegex.matches(in: $0).compactMap { ($0.captures[1]?.string) }
                } ?? []
            }
            .replaceError(with: [])
            .flatMap(Publishers.Sequence.init)
            .eraseToAnyPublisher()
    }
    
    func lyricsFetchPublisher(token: String) -> AnyPublisher<Lyrics, Never> {
        guard let url = URL(string: token, relativeTo: syairLyricsBaseURL) else {
            return Empty().eraseToAnyPublisher()
        }
        var req = URLRequest(url: url)
        req.addValue("https://syair.info/", forHTTPHeaderField: "Referer")
        return sharedURLSession.cx.dataTaskPublisher(for: req)
            .compactMap {
                guard let str = String(data: $0.data, encoding: .utf8),
                    let lrcData = syairLyricsContentRegex.firstMatch(in: str)?.captures[1]?.content.data(using: .utf8),
                    let lrcStr = try? NSAttributedString(data: lrcData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil).string,
                    let lrc = Lyrics(lrcStr) else {
                        return nil
                }
                lrc.metadata.source = .syair
                lrc.metadata.providerToken = token
                return lrc
            }.catch()
            .eraseToAnyPublisher()
    }
}
