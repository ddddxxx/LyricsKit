//
//  LyricsQQ.swift
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

private let qqSearchBaseURLString = "https://c.y.qq.com/soso/fcgi-bin/client_search_cp"
private let qqLyricsBaseURLString = "https://c.y.qq.com/lyric/fcgi-bin/fcg_query_lyric_new.fcg"

extension Lyrics.MetaData.Source {
    static let QQMusic = Lyrics.MetaData.Source("QQMusic")
}

public final class LyricsQQ: MultiResultLyricsProvider {
    
    public static let source: Lyrics.MetaData.Source = .QQMusic
    
    let session = URLSession(configuration: .providerConfig)
    let dispatchGroup = DispatchGroup()
    
    func searchLyricsToken(term: Lyrics.MetaData.SearchTerm, duration: TimeInterval, completionHandler: @escaping ([QQResponseSearchResult.Data.Song.Item]) -> Void) {
        let parameter = ["w": term.description]
        let url = URL(string: qqSearchBaseURLString + "?" + parameter.stringFromHttpParameters)!
        let task = session.dataTask(with: url) { data, resp, error in
            guard let data = data?.dropFirst(9).dropLast(),
                let model = try? JSONDecoder().decode(QQResponseSearchResult.self, from: data) else {
                    completionHandler([])
                    return
            }
            completionHandler(model.songs)
        }
        task.resume()
    }
    
    func getLyricsWithToken(token: QQResponseSearchResult.Data.Song.Item, completionHandler: @escaping (Lyrics?) -> Void) {
        let parameter: [String: Any] = [
            "songmid": token.songmid,
            "g_tk": 5381
        ]
        let url = URL(string: qqLyricsBaseURLString + "?" + parameter.stringFromHttpParameters)!
        var req = URLRequest(url: url)
        req.setValue("y.qq.com/portal/player.html", forHTTPHeaderField: "Referer")
        let task = session.dataTask(with: req) { data, resp, error in
            guard let data = data?.dropFirst(18).dropLast(),
                let model = try? JSONDecoder().decode(QQResponseSingleLyrics.self, from: data),
                let lrcContent = String(data: model.lyric, encoding: .utf8),
                let lrc = Lyrics(lrcContent) else {
                    completionHandler(nil)
                    return
            }
            if let transLrcData = model.trans,
                let transLrcContent = String(data: transLrcData, encoding: .utf8),
                let transLrc = Lyrics(transLrcContent) {
                lrc.merge(translation: transLrc)
            }
            
            lrc.idTags[.title] = token.songname
            lrc.idTags[.artist] = token.singer.first?.name
            lrc.idTags[.album] = token.albumname
            
            lrc.metadata.source = .QQMusic
            if let id = Int(token.songmid) {
                lrc.metadata.artworkURL = URL(string: "http://imgcache.qq.com/music/photo/album/\(id % 100)/\(id).jpg")
            }
            completionHandler(lrc)
        }
        task.resume()
    }
}
