//
//  LyricsTTPod.swift
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

let ttpodLyricsBaseURLString = "http://lp.music.ttpod.com/lrc/down"

extension Lyrics.MetaData.Source {
    static let TTPod = Lyrics.MetaData.Source("TTPod")
}

public final class LyricsTTPod: SingleResultLyricsProvider {
    
    public static let source: Lyrics.MetaData.Source = .TTPod
    
    let session = URLSession(configuration: .providerConfig)
    
    public func iFeelLucky(term: Lyrics.MetaData.SearchTerm, duration: TimeInterval, completionHandler: @escaping (Lyrics?) -> Void) {
        guard case let .info(title, artist) = term else {
            // cannot search by keyword
            completionHandler(nil)
            return
        }
        let parameter: [String: Any] = [
            "artist": artist,
            "title": title,
            ]
        let url = URL(string: ttpodLyricsBaseURLString + "?" + parameter.stringFromHttpParameters)!
        let task = session.dataTask(with: url) { data, resp, error in
            guard let data = data,
                let result = try? JSONDecoder().decode(TTPodResponseSingleLyrics.self, from: data),
                let lrc = Lyrics(result.data.lrc) else {
                    completionHandler(nil)
                    return
            }
            lrc.metadata.source = .TTPod
            lrc.metadata.searchBy = term
            lrc.metadata.searchIndex = 0
            completionHandler(lrc)
        }
        task.resume()
    }
}
