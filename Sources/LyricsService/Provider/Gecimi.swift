//
//  Gecimi.swift
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

private let gecimiLyricsBaseURL = URL(string: "http://gecimi.com/api/lyric")!
private let gecimiCoverBaseURL = URL(string:"http://gecimi.com/api/cover")!

extension LyricsProviders {
    public final class Gecimi {}
}

extension LyricsProviders.Gecimi: _LyricsProvider {
    
    public static let source: LyricsProviderSource = .gecimi
    
    func lyricsSearchPublisher(request: LyricsSearchRequest) -> AnyPublisher<GecimiResponseSearchResult.Result, Never> {
        guard case let .info(title, artist) = request.searchTerm else {
            // cannot search by keyword
            return Empty().eraseToAnyPublisher()
        }
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        let encodedArtist = artist.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        
        let url = gecimiLyricsBaseURL.appendingPathComponent("\(encodedTitle)/\(encodedArtist)")
        let req = URLRequest(url: url)
        
        return sharedURLSession.cx.dataTaskPublisher(for: req)
            .map { $0.data }
            .decode(type: GecimiResponseSearchResult.self, decoder: JSONDecoder().cx)
            .map(\.result)
            .replaceError(with: [])
            .flatMap(Publishers.Sequence.init)
            .eraseToAnyPublisher()
    }
    
    func lyricsFetchPublisher(token: GecimiResponseSearchResult.Result) -> AnyPublisher<Lyrics, Never> {
        return sharedURLSession.cx.dataTaskPublisher(for: token.lrc)
            .compactMap {
                guard let lrcContent = String(data: $0.data, encoding: .utf8),
                    let lrc = Lyrics(lrcContent) else {
                        return nil
                }
                lrc.metadata.remoteURL = token.lrc
                lrc.metadata.source = .gecimi
                lrc.metadata.providerToken = "\(token.aid),\(token.lrc)"
                return lrc
            }.catch()
            .eraseToAnyPublisher()
    }
}
