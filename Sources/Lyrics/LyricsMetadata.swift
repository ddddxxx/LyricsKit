//
//  LyricsMetadata.swift
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

extension Lyrics.MetaData.Key {
    public static var source        = Lyrics.MetaData.Key("source")
    public static var title         = Lyrics.MetaData.Key("title")
    public static var artist        = Lyrics.MetaData.Key("artist")
    public static var request       = Lyrics.MetaData.Key("request")
    public static var searchIndex   = Lyrics.MetaData.Key("searchIndex")
    public static var lyricsURL     = Lyrics.MetaData.Key("lyricsURL")
    public static var artworkURL    = Lyrics.MetaData.Key("artworkURL")
    public static var attachmentTags = Lyrics.MetaData.Key("attachmentTags")
}

extension Lyrics.MetaData {
    
    public var source: Source {
        get { return data[.source] as? Source ?? .Unknown }
        set { data[.source] = newValue }
    }
    
    public var title: String? {
        get { return data[.title] as? String }
        set { data[.title] = newValue }
    }
    
    public var artist: String? {
        get { return data[.artist] as? String }
        set { data[.artist] = newValue }
    }
    
    public var request: LyricsSearchRequest? {
        get { return data[.request] as? LyricsSearchRequest }
        set { data[.request] = newValue }
    }
    
    public var searchIndex: Int {
        get { return data[.searchIndex] as? Int ?? 0 }
        set { data[.searchIndex] = newValue }
    }
    
    public var lyricsURL: URL? {
        get { return data[.lyricsURL] as? URL }
        set { data[.lyricsURL] = newValue }
    }
    
    public var artworkURL: URL? {
        get { return data[.artworkURL] as? URL }
        set { data[.artworkURL] = newValue }
    }
    
    public var attachmentTags: Set<LyricsLineAttachmentTag> {
        get { return data[.attachmentTags] as? Set<LyricsLineAttachmentTag> ?? [] }
        set { data[.attachmentTags] = newValue }
    }
}
