//
//  Lyrics.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/5.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

struct Lyrics {
    
    var lyrics: [LyricsLine]
    var idTags: [IDTagKey: String]
    var metadata: MetaData
    
    var offset: Int {
        get {
            return idTags[.offset].flatMap() { Int($0) } ?? 0
        }
        set {
            idTags[.offset] = "\(newValue)"
        }
    }
    
    var timeDelay: TimeInterval {
        get {
            return TimeInterval(offset) / 1000
        }
        set {
            offset = Int(newValue * 1000)
        }
    }
    
    private static let idTagRegex = try! NSRegularExpression(pattern: "\\[[^\\]]+:[^\\]]+\\]")
    private static let timeTagRegex = try! NSRegularExpression(pattern: "\\[\\d+:\\d+.\\d+\\]|\\[\\d+:\\d+\\]")
    
    init?(_ lrcContents: String) {
        lyrics = []
        idTags = [:]
        metadata = MetaData(source: .Unknown)
        
        let lyricsLines = lrcContents.components(separatedBy: .newlines)
        for line in lyricsLines {
            let timeTagsMatched = Lyrics.timeTagRegex.matches(in: line, options: [], range: line.range)
            if timeTagsMatched.count > 0 {
                let index: Int = timeTagsMatched.last!.range.location + timeTagsMatched.last!.range.length
                let lyricsSentence: String = line.substring(from: line.characters.index(line.startIndex, offsetBy: index))
                let components = lyricsSentence.components(separatedBy: "【")
                let lyricsStr: String
                let translation: String?
                if components.count == 2, components[1].characters.last == "】" {
                    lyricsStr = components[0]
                    translation = String(components[1].characters.dropLast())
                } else {
                    lyricsStr = lyricsSentence
                    translation = nil
                }
                let lyrics = timeTagsMatched.flatMap() { result -> LyricsLine? in
                    let timeTagStr = (line as NSString).substring(with: result.range) as String
                    return LyricsLine(sentence: lyricsStr, translation: translation, timeTag: timeTagStr)
                }
                self.lyrics += lyrics
            } else {
                let idTagsMatched = Lyrics.idTagRegex.matches(in: line, range: line.range)
                guard idTagsMatched.count > 0 else {
                    continue
                }
                for result in idTagsMatched {
                    var tagStr = ((line as NSString).substring(with: result.range)) as String
                    tagStr.remove(at: tagStr.startIndex)
                    tagStr.remove(at: tagStr.index(before: tagStr.endIndex))
                    let components = tagStr.components(separatedBy: ":")
                    if components.count == 2 {
                        let key = IDTagKey(components[0])
                        let value = components[1]
                        idTags[key] = value
                    }
                }
            }
        }
        
        if lyrics.count == 0 {
            return nil
        }
        
        lyrics.sort() { $0.position < $1.position }
    }
    
    init?(url: URL) {
        guard let lrcContent = try? String(contentsOf: url) else {
            return nil
        }
        
        self.init(lrcContent)
        metadata.lyricsURL = url
    }
    
    subscript(_ position: TimeInterval) -> (current:LyricsLine?, next:LyricsLine?) {
        let lyrics = self.lyrics.filter() { $0.enabled }
        guard let index = lyrics.index(where: { $0.position - timeDelay > position }) else {
            return (lyrics.last, nil)
        }
        let previous = lyrics.index(index, offsetBy: -1, limitedBy: lyrics.startIndex).flatMap() { lyrics[$0] }
        return (previous, lyrics[index])
    }
    
    struct IDTagKey: RawRepresentable, Hashable {
        
        var rawValue: String
        
        init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        var hashValue: Int {
            return rawValue.hash
        }
        
        static let title    = IDTagKey("ti")
        static let album    = IDTagKey("al")
        static let artist   = IDTagKey("ar")
        static let author   = IDTagKey("au")
        static let lrcBy    = IDTagKey("by")
        static let offset   = IDTagKey("offset")
    }
    
    struct MetaData {
        
        var source: Source
        var title: String?
        var artist: String?
        var searchBy: SearchCriteria?
        var searchIndex: Int
        var lyricsURL: URL?
        var artworkURL: URL?
        var includeTranslation: Bool
        
        init(source: Source, title: String? = nil, artist: String? = nil, searchBy: SearchCriteria? = nil, searchIndex: Int = 0, lyricsURL: URL? = nil, artworkURL: URL? = nil, includeTranslation: Bool = false) {
            self.source = source
            self.title = title
            self.artist = artist
            self.searchBy = searchBy
            self.searchIndex = searchIndex
            self.lyricsURL = lyricsURL
            self.artworkURL = artworkURL
            self.includeTranslation = includeTranslation
        }
        
        struct Source: RawRepresentable {
            var rawValue: String
            
            init(rawValue: String) {
                self.rawValue = rawValue
            }
            
            init(_ rawValue: String) {
                self.rawValue = rawValue
            }
            
            static let Unknown = Source("unknown")
            static let Local = Source("Local")
            static let Import = Source("Import")
        }
        
        enum SearchCriteria {
            case keyword(String)
            case info(title: String, artist: String)
        }
    }
}

extension Lyrics {
    
    func contentString(withMetadata: Bool, ID3: Bool, timeTag: Bool, translation: Bool) -> String {
        var content = ""
//        if withMetadata {
//            content += metadata.map {
//                return "[\($0.key):\($0.value)]\n"
//            }.joined()
//        }
        if ID3 {
            content += idTags.map() {
                return "[\($0.key.rawValue):\($0.value)]\n"
            }.joined()
        }
        
        content += lyrics.map() {
            return $0.contentString(withTimeTag: timeTag, translation: translation) + "\n"
        }.joined()
        
        return content
    }
}

extension Lyrics {
    
    mutating func filtrate(using regex: NSRegularExpression) {
        for (index, lyric) in lyrics.enumerated() {
            let sentence = lyric.sentence.replacingOccurrences(of: " ", with: "")
            let numberOfMatches = regex.numberOfMatches(in: sentence, options: [], range: sentence.range)
            if numberOfMatches > 0 {
                lyrics[index].enabled = false
                continue
            }
        }
    }
    
    mutating func smartFiltrate() {
        for (index, lyric) in lyrics.enumerated() {
            let sentence = lyric.sentence
            if let idTagTitle = idTags[.title],
                let idTagArtist = idTags[.artist],
                sentence.contains(idTagTitle),
                sentence.contains(idTagArtist) {
                lyrics[index].enabled = false
            } else if let iTunesTitle = metadata.title,
                let iTunesArtist = metadata.artist,
                sentence.contains(iTunesTitle),
                sentence.contains(iTunesArtist) {
                lyrics[index].enabled = false
            }
        }
    }
}

infix operator ?>
private func ?>(lhs: Bool?, rhs: Bool?) -> Bool? {
    switch (lhs, rhs) {
    case (true?, true?), (false?, false?):
        return nil
    case (true?, _), (_, false?):
        return true
    case (_, true?), (false?, _):
        return false
    default:
        return nil
    }
}

extension Lyrics {
    
    static func >(lhs: Lyrics, rhs: Lyrics) -> Bool {
        if lhs.metadata.source == rhs.metadata.source  {
            return lhs.metadata.searchIndex < rhs.metadata.searchIndex
        }
        
        if let artistComparison = lhs.isFitArtist ?> rhs.isFitArtist {
            return artistComparison
        }
        
        if let artistComparison = lhs.isApproachArtise ?> rhs.isApproachArtise {
            return artistComparison
        }
        
        if let titleComparison = lhs.isFitTitle ?> rhs.isFitTitle {
            return titleComparison
        }
        
        if let titleComparison = lhs.isApproachTitle ?> rhs.isApproachTitle {
            return titleComparison
        }
        
        if let translationComparison = lhs.metadata.includeTranslation ?> rhs.metadata.includeTranslation {
            return translationComparison
        }
        
        return false
    }
    
    static func <(lhs: Lyrics, rhs: Lyrics) -> Bool {
        return rhs > lhs
    }
    
    static func >=(lhs: Lyrics, rhs: Lyrics) -> Bool {
        return !(lhs < rhs)
    }
    
    static func <=(lhs: Lyrics, rhs: Lyrics) -> Bool {
        return !(lhs > rhs)
    }
    
    private var isFitArtist: Bool? {
        guard let searchArtist = metadata.artist,
            let artist = idTags[.artist] else {
            return nil
        }
        
        return searchArtist == artist
    }
    
    private var isApproachArtise: Bool? {
        guard let searchArtist = metadata.artist,
            let artist = idTags[.artist] else {
                return nil
        }
        
        let s1 = searchArtist.lowercased().replacingOccurrences(of: " ", with: "")
        let s2 = artist.lowercased().replacingOccurrences(of: " ", with: "")
        
        return s1.contains(s2) || s2.contains(s1)
    }
    
    private var isFitTitle: Bool? {
        guard let searchTitle = metadata.title,
            let title = idTags[.title] else {
                return nil
        }
        
        return searchTitle == title
    }
    
    private var isApproachTitle: Bool? {
        guard let searchTitle = metadata.title,
            let title = idTags[.title] else {
                return nil
        }
        
        let s1 = searchTitle.lowercased().replacingOccurrences(of: " ", with: "")
        let s2 = title.lowercased().replacingOccurrences(of: " ", with: "")
        
        return s1.contains(s2) || s2.contains(s1)
    }
}

extension Lyrics.MetaData.Source: Equatable {
    static func ==(lhs: Lyrics.MetaData.Source, rhs: Lyrics.MetaData.Source) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension Lyrics.MetaData.SearchCriteria: Equatable {
    static func ==(lhs: Lyrics.MetaData.SearchCriteria, rhs: Lyrics.MetaData.SearchCriteria) -> Bool {
        switch (lhs, rhs) {
        case (.keyword, .info), (.info, .keyword):
            return false
        case (let .keyword(l), let .keyword(r)):
            return l == r
        case (let .info(l1, l2), let .info(r1, r2)):
            return (l1 == r1) && (l2 == r2)
        }
    }
}

extension Lyrics.IDTagKey: CustomStringConvertible {
    
    public var description: String {
        return rawValue
    }
}

extension Lyrics: CustomStringConvertible {
    
    public var description: String {
        return contentString(withMetadata: true, ID3: true, timeTag: true, translation: true)
    }
}
