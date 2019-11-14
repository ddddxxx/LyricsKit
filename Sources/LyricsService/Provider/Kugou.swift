//
//  LyricsKugou.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation
import LyricsCore
import CXShim

private let kugouSearchBaseURLString = "http://lyrics.kugou.com/search"
private let kugouLyricsBaseURLString = "http://lyrics.kugou.com/download"

extension LyricsProviders {
    public final class Kugou {}
}

extension LyricsProviders.Kugou: _LyricsProvider {
    
    public static let source: LyricsProviderSource = .kugou
    
    func lyricsSearchPublisher(request: LyricsSearchRequest) -> AnyPublisher<KugouResponseSearchResult.Item, Never> {
        let parameter: [String: Any] = [
            "keyword": request.searchTerm.description,
            "duration": Int(request.duration * 1000),
            "client": "pc",
            "ver": 1,
            "man": "yes",
            ]
        let url = URL(string: kugouSearchBaseURLString + "?" + parameter.stringFromHttpParameters)!
        return sharedURLSession.cx.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: KugouResponseSearchResult.self, decoder: JSONDecoder().cx)
            .map(\.candidates)
            .replaceError(with: [])
            .flatMap(Publishers.Sequence.init)
            .eraseToAnyPublisher()
    }
    
    func lyricsFetchPublisher(token: KugouResponseSearchResult.Item) -> AnyPublisher<Lyrics, Never> {
        let parameter: [String: Any] = [
            "id": token.id,
            "accesskey": token.accesskey,
            "fmt": "krc",
            "charset": "utf8",
            "client": "pc",
            "ver": 1,
        ]
        let url = URL(string: kugouLyricsBaseURLString + "?" + parameter.stringFromHttpParameters)!
        return sharedURLSession.cx.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: KugouResponseSingleLyrics.self, decoder: JSONDecoder().cx)
            .compactMap {
                guard let lrcContent = decryptKugouKrc($0.content),
                    let lrc = Lyrics(kugouKrcContent: lrcContent) else {
                        return nil
                }
                lrc.idTags[.title] = token.song
                lrc.idTags[.artist] = token.singer
                lrc.idTags[.lrcBy] = "Kugou"
                
                lrc.length = Double(token.duration)/1000
                lrc.metadata.source = .kugou
                lrc.metadata.providerToken = "\(token.id),\(token.accesskey)"
                return lrc
            }.catch()
            .eraseToAnyPublisher()
    }
}
