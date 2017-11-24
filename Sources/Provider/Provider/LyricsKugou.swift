//
//  LyricsKugou.swift
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

private let kugouSearchBaseURLString = "http://lyrics.kugou.com/search"
private let kugouLyricsBaseURLString = "http://lyrics.kugou.com/download"

extension Lyrics.MetaData.Source {
    static let kugou = Lyrics.MetaData.Source("Kugou")
}

public final class LyricsKugou: MultiResultLyricsProvider {
    
    public static let source: Lyrics.MetaData.Source = .kugou
    
    let session = URLSession(configuration: .providerConfig)
    let dispatchGroup = DispatchGroup()
    
    func searchLyricsToken(request: LyricsSearchRequest, completionHandler: @escaping ([KugouResponseSearchResult.Item]) -> Void) {
        let parameter: [String: Any] = [
            "keyword": request.searchTerm.description,
            "duration": Int(request.duration * 1000),
            "client": "pc",
            "ver": 1,
            "man": "yes",
            ]
        let url = URL(string: kugouSearchBaseURLString + "?" + parameter.stringFromHttpParameters)!
        let task = session.dataTask(with: url, type: KugouResponseSearchResult.self) { model, error in
            completionHandler(model?.candidates ?? [])
        }
        task.resume()
    }
    
    func getLyricsWithToken(token: KugouResponseSearchResult.Item, completionHandler: @escaping (Lyrics?) -> Void) {
        let parameter: [String: Any] = [
            "id": token.id,
            "accesskey": token.accesskey,
            "fmt": "krc",
            "charset": "utf8",
            "client": "pc",
            "ver": 1,
            ]
        let url = URL(string: kugouLyricsBaseURLString + "?" + parameter.stringFromHttpParameters)!
        let task = session.dataTask(with: url, type: KugouResponseSingleLyrics.self) { model, error in
            guard let model = model,
                let lrcContent = decryptKugouKrc(model.content),
                let lrc = Lyrics(kugouKrcContent: lrcContent) else {
                    completionHandler(nil)
                    return
            }
            lrc.idTags[.title] = token.song
            lrc.idTags[.artist] = token.singer
            lrc.idTags[.lrcBy] = "Kugou"
            
            lrc.metadata.source = .kugou
            
            completionHandler(lrc)
        }
        task.resume()
    }
}
