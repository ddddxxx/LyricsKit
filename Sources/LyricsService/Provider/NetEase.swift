//
//  LyricsNetEase.swift
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

private let netEaseSearchBaseURLString = "http://music.163.com/api/search/pc?"
private let netEaseLyricsBaseURLString = "http://music.163.com/api/song/lyric?"

extension LyricsProviders {
    public final class NetEase {}
}

extension LyricsProviders.NetEase: _LyricsProvider {
    
    public static let source: LyricsProviderSource = .netease
    
    func lyricsSearchPublisher(request: LyricsSearchRequest) -> AnyPublisher<NetEaseResponseSearchResult.Result.Song, Never> {
        let parameter: [String: Any] = [
            "s": request.searchTerm.description,
            "offset": 0,
            "limit": 10,
            "type": 1,
            ]
        let url = URL(string: netEaseSearchBaseURLString + parameter.stringFromHttpParameters)!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("http://music.163.com/", forHTTPHeaderField: "Referer")
        
        return sharedURLSession.cx.dataTaskPublisher(for: req)
            .map { $0.data }
            .decode(type: NetEaseResponseSearchResult.self, decoder: JSONDecoder().cx)
            .map(\.songs)
            .replaceError(with: [])
            .flatMap(Publishers.Sequence.init)
            .eraseToAnyPublisher()
    }
    
    func lyricsFetchPublisher(token: NetEaseResponseSearchResult.Result.Song) -> AnyPublisher<Lyrics, Never> {
        let parameter: [String: Any] = [
            "id": token.id,
            "lv": 1,
            "kv": 1,
            "tv": -1,
        ]
        let url = URL(string: netEaseLyricsBaseURLString + parameter.stringFromHttpParameters)!
        return sharedURLSession.cx.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: NetEaseResponseSingleLyrics.self, decoder: JSONDecoder().cx)
            .compactMap {
                let lyrics: Lyrics
                let transLrc = ($0.tlyric?.lyric).flatMap(Lyrics.init)
                if let kLrc = ($0.klyric?.lyric).flatMap(Lyrics.init(netEaseKLyricContent:)) {
                    transLrc.map(kLrc.forceMerge)
                    lyrics = kLrc
                } else if let lrc = ($0.lrc?.lyric).flatMap(Lyrics.init) {
                    transLrc.map(lrc.merge)
                    lyrics = lrc
                } else {
                    return nil
                }
                
                // FIXME: merge inline time tags back to lyrics
                // if let taggedLrc = (model.klyric?.lyric).flatMap(Lyrics.init(netEaseKLyricContent:))
                
                lyrics.idTags[.title]   = token.name
                lyrics.idTags[.artist]  = token.artists.first?.name
                lyrics.idTags[.album]   = token.album.name
                lyrics.idTags[.lrcBy]   = $0.lyricUser?.nickname
                
                lyrics.length = Double(token.duration) / 1000
                lyrics.metadata.source      = .netease
                lyrics.metadata.artworkURL  = token.album.picUrl
                lyrics.metadata.providerToken = "\(token.id)"
                
                return lyrics
            }.catch()
            .eraseToAnyPublisher()
    }
}
