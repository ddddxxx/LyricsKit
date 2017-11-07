//
//  LyricsNetEase.swift
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

private let netEaseSearchBaseURLString = "http://music.163.com/api/search/pc?"
private let netEaseLyricsBaseURLString = "http://music.163.com/api/song/lyric?"

extension Lyrics.MetaData.Source {
    public static let netease = Lyrics.MetaData.Source("163")
}

public final class LyricsNetEase: MultiResultLyricsProvider {
    
    public static let source: Lyrics.MetaData.Source = .netease
    
    let session = URLSession(configuration: .providerConfig)
    let dispatchGroup = DispatchGroup()
    
    func searchLyricsToken(term: Lyrics.MetaData.SearchTerm, duration: TimeInterval, completionHandler: @escaping ([NetEaseResponseSearchResult.Result.Song]) -> Void) {
        let parameter: [String: Any] = [
            "s": term.description,
            "offset": 0,
            "limit": 10,
            "type": 1,
            ]
        let url = URL(string: netEaseSearchBaseURLString + parameter.stringFromHttpParameters)!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("http://music.163.com/", forHTTPHeaderField: "Referer")
        let task = session.dataTask(with: req, type: NetEaseResponseSearchResult.self) { model, error in
            completionHandler(model?.songs ?? [])
        }
        task.resume()
    }
    
    func getLyricsWithToken(token: NetEaseResponseSearchResult.Result.Song, completionHandler: @escaping (Lyrics?) -> Void) {
        let parameter: [String: Any] = [
            "id": token.id,
            "lv": 1,
            "kv": 1,
            "tv": -1,
            ]
        let url = URL(string: netEaseLyricsBaseURLString + parameter.stringFromHttpParameters)!
        let task = session.dataTask(with: url, type: NetEaseResponseSingleLyrics.self) { model, error in
            guard let model = model,
                let lrc = (model.klyric?.lyric).flatMap(Lyrics.init(netEaseKLyricContent:))
                ?? (model.lrc?.lyric).flatMap(Lyrics.init) else {
                    completionHandler(nil)
                    return
            }
            if let transLrcContent = model.tlyric?.lyric,
                let transLrc = Lyrics(transLrcContent) {
                lrc.merge(translation: transLrc)
            }
            
            lrc.idTags[.title]   = token.name
            lrc.idTags[.artist]  = token.artists.first?.name
            lrc.idTags[.album]   = token.album.name
            lrc.idTags[.lrcBy]   = model.lyricUser?.nickname
            
            lrc.metadata.source      = .netease
            lrc.metadata.artworkURL  = token.album.picUrl
            
            completionHandler(lrc)
        }
        task.resume()
    }
}
