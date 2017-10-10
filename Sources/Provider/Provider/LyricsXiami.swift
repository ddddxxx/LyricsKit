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

private let xiamiSearchBaseURLString = "http://www.xiami.com/web/search-songs"
private let xiamiLyricsBaseURL = URL(string: "http://www.xiami.com/song/playlist/id")!

extension Lyrics.MetaData.Source {
    static let Xiami = Lyrics.MetaData.Source("Xiami")
}

public final class LyricsXiami: MultiResultLyricsProvider {
    
    public static let source: Lyrics.MetaData.Source = .Xiami
    
    let session = URLSession(configuration: .providerConfig)
    let dispatchGroup = DispatchGroup()
    
    func searchLyricsToken(term: Lyrics.MetaData.SearchTerm, duration: TimeInterval, completionHandler: @escaping ([XiamiResponseSearchResultItem]) -> Void) {
        let parameter = ["key": term.description]
        let url = URL(string: xiamiSearchBaseURLString + "?" + parameter.stringFromHttpParameters)!
        let task = session.dataTask(with: url) { data, resp, error in
            guard let data = data,
                let result = try? JSONDecoder().decode(XiamiResponseSearchResult.self, from: data) else {
                    completionHandler([])
                    return
            }
            completionHandler(result)
        }
        task.resume()
    }
    
    func getLyricsWithToken(token: XiamiResponseSearchResultItem, completionHandler: @escaping (Lyrics?) -> Void) {
        let url = xiamiLyricsBaseURL.appendingPathComponent("\(token.id)")
        let req = URLRequest(url: url)
        let task = session.dataTask(with: req) { data, resp, error in
            guard let data = data,
                let parseResult = LyricsXiamiXMLParser().parseLrcURL(data: data),
                // FIXME: async fetch lyrics
                let lrcStr = try? String(contentsOf: parseResult.lyricsURL),
                let lrc = Lyrics(lrcStr) else {
                completionHandler(nil)
                return
            }
            lrc.idTags[.title] = token.title
            lrc.idTags[.artist] = token.author
            
            lrc.metadata.lyricsURL = parseResult.lyricsURL
            lrc.metadata.source = .Xiami
            lrc.metadata.artworkURL = parseResult.artworkURL
            completionHandler(lrc)
        }
        task.resume()
    }
}

// MARK: - XMLParser

private class LyricsXiamiXMLParser: NSObject, XMLParserDelegate {
    
    var XMLContent: String?
    
    var lyricsURL: URL?
    var artworkURL: URL?
    
    func parseLrcURL(data: Data) -> (lyricsURL: URL, artworkURL: URL?)? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        guard let lyricsURL = lyricsURL else {
            return nil
        }
        
        return (lyricsURL, artworkURL)
    }
    
    // MARK: XMLParserDelegate
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "lyric":
            lyricsURL = XMLContent.flatMap { URL(string: $0) }
        case "pic":
            artworkURL = XMLContent.flatMap { URL(string: $0) }
        default:
            return
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        XMLContent = string
    }
}
