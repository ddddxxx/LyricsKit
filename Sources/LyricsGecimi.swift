//
//  LyricsGecimi.swift
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

extension Lyrics.MetaData.Source {
    static let Gecimi = Lyrics.MetaData.Source("Gecimi")
}

public final class LyricsGecimi: MultiResultLyricsProvider {
    
    public static let source: Lyrics.MetaData.Source = .Gecimi
    
    let session = URLSession(configuration: .providerConfig)
    let dispatchGroup = DispatchGroup()
    
    func searchLyricsToken(criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, completionHandler: @escaping ([JSON]) -> Void) {
        guard case let .info(title, artist) = criteria else {
            // cannot search by keyword
            completionHandler([])
            return
        }
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        let encodedArtist = artist.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        
        let url = URL(string: "http://gecimi.com/api/lyric/\(encodedTitle)/\(encodedArtist)")!
        let req = URLRequest(url: url)
        let task = session.dataTask(with: req) { data, resp, error in
            let json = data.map(JSON.init)?["result"].array ?? []
            completionHandler(json)
        }
        task.resume()
    }
    
    func getLyricsWithToken(token: JSON, completionHandler: @escaping (Lyrics?) -> Void) {
        guard let lrcURL = token["lrc"].url else {
            completionHandler(nil)
            return
        }
        let task = session.dataTask(with: lrcURL) { data, resp, error in
            guard let data = data,
                let lrcContent = String(data: data, encoding: .utf8),
                let lyrics = Lyrics(lrcContent)else {
                completionHandler(nil)
                return
            }
            lyrics.metadata.lyricsURL = lrcURL
            lyrics.metadata.source = .Gecimi
            
            if let aid = token["aid"].string,
                let url = URL(string:"http://gecimi.com/api/cover/\(aid)") {
                let task = self.session.dataTask(with: url) { data, resp, error in
                    lyrics.metadata.artworkURL = data.map(JSON.init)?["result"]["cover"].url
                }
                task.resume()
            }
            
            completionHandler(lyrics)
        }
        task.resume()
    }
}
