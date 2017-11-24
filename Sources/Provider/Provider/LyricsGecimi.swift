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

private let gecimiLyricsBaseURL = URL(string: "http://gecimi.com/api/lyric")!
private let gecimiCoverBaseURL = URL(string:"http://gecimi.com/api/cover")!

extension Lyrics.MetaData.Source {
    static let gecimi = Lyrics.MetaData.Source("Gecimi")
}

public final class LyricsGecimi: MultiResultLyricsProvider {
    
    public static let source: Lyrics.MetaData.Source = .gecimi
    
    let session = URLSession(configuration: .providerConfig)
    let dispatchGroup = DispatchGroup()
    
    func searchLyricsToken(request: LyricsSearchRequest, completionHandler: @escaping ([GecimiResponseSearchResult.Result]) -> Void) {
        guard case let .info(title, artist) = request.searchTerm else {
            // cannot search by keyword
            completionHandler([])
            return
        }
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        let encodedArtist = artist.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        
        let url = gecimiLyricsBaseURL.appendingPathComponent("\(encodedTitle)/\(encodedArtist)")
        let req = URLRequest(url: url)
        let task = session.dataTask(with: req, type: GecimiResponseSearchResult.self) { model, error in
            completionHandler(model?.result ?? [])
        }
        task.resume()
    }
    
    func getLyricsWithToken(token: GecimiResponseSearchResult.Result, completionHandler: @escaping (Lyrics?) -> Void) {
        let task = session.dataTask(with: token.lrc) { data, resp, error in
            guard let data = data,
                let lrcContent = String(data: data, encoding: .utf8),
                let lyrics = Lyrics(lrcContent)else {
                completionHandler(nil)
                return
            }
            lyrics.metadata.lyricsURL = token.lrc
            lyrics.metadata.source = .gecimi
            
            let url = gecimiCoverBaseURL.appendingPathComponent("\(token.aid)")
            let task = self.session.dataTask(with: url, type: GecimiResponseCover.self) { model, error in
                if let model = model {
                    lyrics.metadata.artworkURL = model.result.cover
                }
            }
            task.resume()
            
            completionHandler(lyrics)
        }
        task.resume()
    }
}
