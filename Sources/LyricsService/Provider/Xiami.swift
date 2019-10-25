//
//  LyricsXiami.swift
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

private let xiamiSearchBaseURLString = "http://api.xiami.com/web?"

extension LyricsProviders {
    public final class Xiami {}
}

extension LyricsProviders.Xiami: _LyricsProvider {
    
    public static let source: LyricsProviderSource = .xiami
    
    func lyricsSearchPublisher(request: LyricsSearchRequest) -> AnyPublisher<XiamiResponseSearchResult.Data.Song, Never> {
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
            .map { $0.data }
            .decode(type: XiamiResponseSearchResult.self, decoder: JSONDecoder().cx)
            .map { $0.data.songs.filter { $0.lyric != nil } }
            .replaceError(with: [])
            .flatMap(Publishers.Sequence.init)
            .eraseToAnyPublisher()
    }
    
    func lyricsFetchPublisher(token: XiamiResponseSearchResult.Data.Song) -> AnyPublisher<Lyrics, Never> {
        guard let lrcURLStr = token.lyric,
            let lrcURL = URL(string: lrcURLStr) else {
                return Empty().eraseToAnyPublisher()
        }
        return sharedURLSession.cx.dataTaskPublisher(for: lrcURL)
            .compactMap {
                guard let lrcStr = String(data: $0.data, encoding: .utf8),
                    let lrc = Lyrics(ttpodXtrcContent:lrcStr) else {
                        return nil
                }
                lrc.idTags[.title] = token.song_name
                lrc.idTags[.artist] = token.artist_name
                
                lrc.metadata.remoteURL = lrcURL
                lrc.metadata.source = .xiami
                lrc.metadata.artworkURL = token.album_logo
                lrc.metadata.providerToken = token.lyric
                return lrc
            }.catch()
            .eraseToAnyPublisher()
    }
}
