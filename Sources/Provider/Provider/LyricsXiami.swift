//
//  LyricsXiami.swift
//
//  This file is part of LyricsX
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

private let xiamiSearchBaseURLString = "http://api.xiami.com/web?"

extension Lyrics.MetaData.Source {
    static let xiami = Lyrics.MetaData.Source("Xiami")
}

public final class LyricsXiami: MultiResultLyricsProvider {
    
    public static let source: Lyrics.MetaData.Source = .xiami
    
    let session = URLSession(configuration: .providerConfig)
    let dispatchGroup = DispatchGroup()
    
    func searchLyricsToken(term: Lyrics.MetaData.SearchTerm, duration: TimeInterval, completionHandler: @escaping ([XiamiResponseSearchResult.Data.Song]) -> Void) {
        let parameter: [String : Any] = [
            "key": term.description,
            "limit": 10,
            "r": "search/songs",
            "v": "2.0",
            "app_key": 1,
        ]
        let url = URL(string: xiamiSearchBaseURLString + parameter.stringFromHttpParameters)!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("http://h.xiami.com/", forHTTPHeaderField: "Referer")
        let task = session.dataTask(with: req, type: XiamiResponseSearchResult.self) { model, error in
            let songs = model?.data.songs.filter { $0.lyric != nil } ?? []
            completionHandler(songs)
        }
        task.resume()
    }
    
    func getLyricsWithToken(token: XiamiResponseSearchResult.Data.Song, completionHandler: @escaping (Lyrics?) -> Void) {
        guard let lrcURLStr = token.lyric,
            let lrcURL = URL(string: lrcURLStr) else {
            completionHandler(nil)
            return
        }
        let task = session.dataTask(with: lrcURL) { data, resp, error in
            let parser: (String) -> Lyrics?
            switch lrcURL.pathExtension.lowercased() {
            case "lrc":
                parser = Lyrics.init
            case "trc", "xtrc":
                parser = Lyrics.init(ttpodXtrcContent:)
            default:
                // TODO: unknown format
                parser = { _ in nil }
            }
            guard let data = data,
                let lrcStr = String.init(data: data, encoding: .utf8),
                let lrc = parser(lrcStr) else {
                completionHandler(nil)
                return
            }
            lrc.idTags[.title] = token.song_name
            lrc.idTags[.artist] = token.artist_name
            
            lrc.metadata.lyricsURL = lrcURL
            lrc.metadata.source = .xiami
            lrc.metadata.artworkURL = token.album_logo
            completionHandler(lrc)
        }
        task.resume()
    }
}
