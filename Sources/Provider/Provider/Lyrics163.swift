//
//  Lyrics163.swift
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
    public static let Music163 = Lyrics.MetaData.Source("163")
}

public final class Lyrics163: MultiResultLyricsProvider {
    
    public static let source: Lyrics.MetaData.Source = .Music163
    
    let session = URLSession(configuration: .providerConfig)
    let dispatchGroup = DispatchGroup()
    
    func searchLyricsToken(term: Lyrics.MetaData.SearchTerm, duration: TimeInterval, completionHandler: @escaping ([NetEaseResponseSearchResult.Result.Song]) -> Void) {
        let keyword = term.description
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        let url = URL(string: "http://music.163.com/api/search/pc")!
        let body = "s=\(encodedKeyword)&offset=0&limit=10&type=1".data(using: .utf8)!
        
        let req = URLRequest(url: url).with {
            $0.httpMethod = "POST"
            $0.setValue("appver=1.5.0.75771", forHTTPHeaderField: "Cookie")
            $0.setValue("http://music.163.com/", forHTTPHeaderField: "Referer")
            $0.httpBody = body
        }
        let task = session.dataTask(with: req) { data, resp, error in
            guard let data = data,
                let result = try? JSONDecoder().decode(NetEaseResponseSearchResult.self, from: data) else {
                completionHandler([])
                return
            }
            completionHandler(result.songs)
        }
        task.resume()
    }
    
    func getLyricsWithToken(token: NetEaseResponseSearchResult.Result.Song, completionHandler: @escaping (Lyrics?) -> Void) {
        let url = URL(string: "http://music.163.com/api/song/lyric?id=\(token.id)&lv=1&kv=1&tv=-1")!
        let req = URLRequest(url: url)
        let task = session.dataTask(with: req) { data, resp, error in
            guard let data = data,
                let result = try? JSONDecoder().decode(NetEaseResponseSingleLyrics.self, from: data),
                let lrcContent = result.lrc?.lyric,
                let lrc = Lyrics(lrcContent) else {
                    completionHandler(nil)
                    return
            }
            if let transLrcContent = result.tlyric?.lyric,
                let transLrc = Lyrics(transLrcContent) {
                lrc.merge(translation: transLrc)
                lrc.metadata.includeTranslation = true
            }
            
            lrc.idTags[.title]   = token.name
            lrc.idTags[.artist]  = token.artists.first?.name
            lrc.idTags[.album]   = token.album.name
            lrc.idTags[.lrcBy]   = result.lyricUser?.nickname
            
            lrc.metadata.source      = .Music163
            lrc.metadata.artworkURL  = token.album.picUrl
            
            completionHandler(lrc)
        }
        task.resume()
    }
}

extension Lyrics {
    
    fileprivate func merge(translation: Lyrics) {
        var index = lines.startIndex
        var transIndex = translation.lines.startIndex
        while index < lines.endIndex, transIndex < translation.lines.endIndex {
            if lines[index].position == translation.lines[transIndex].position {
                let transStr = translation.lines[transIndex].content
                if !transStr.isEmpty {
                    let translation = LyricsLineAttachmentPlainText(transStr)
                    lines[index].attachments[.translation] = translation
                }
                lines.formIndex(after: &index)
                translation.lines.formIndex(after: &transIndex)
            } else if lines[index].position > translation.lines[transIndex].position {
                translation.lines.formIndex(after: &transIndex)
            } else {
                lines.formIndex(after: &index)
            }
        }
    }
}
