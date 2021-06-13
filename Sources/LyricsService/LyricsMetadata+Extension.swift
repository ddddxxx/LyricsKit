//
//  LyricsMetadata+Extension.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LyricsCore

extension Lyrics.Metadata.Key {
    public static var request       = Lyrics.Metadata.Key("request")
    public static var remoteURL     = Lyrics.Metadata.Key("remoteURL")
    public static var artworkURL    = Lyrics.Metadata.Key("artworkURL")
    public static var service       = Lyrics.Metadata.Key("service")
    public static var serviceToken  = Lyrics.Metadata.Key("serviceToken")
    static var quality              = Lyrics.Metadata.Key("quality")
    
    static var searchIndex          = Lyrics.Metadata.Key("searchIndex")
}

extension Lyrics.Metadata {
    
    public var request: LyricsSearchRequest? {
        get { return data[.request] as? LyricsSearchRequest }
        set { data[.request] = newValue }
    }
    
    public var remoteURL: URL? {
        get { return data[.remoteURL] as? URL }
        set { data[.remoteURL] = newValue }
    }
    
    public var artworkURL: URL? {
        get { return data[.artworkURL] as? URL }
        set { data[.artworkURL] = newValue }
    }
    
    public var service: LyricsProviders.Service? {
        get { return data[.service] as? LyricsProviders.Service }
        set { data[.service] = newValue }
    }
    
    public var serviceToken: String? {
        get { return data[.serviceToken] as? String }
        set { data[.serviceToken] = newValue }
    }
    
    var quality: Double? {
        get { return data[.quality] as? Double }
        set { data[.quality] = newValue }
    }
    
    var searchIndex: Int {
        get { return data[.searchIndex] as? Int ?? 0 }
        set { data[.searchIndex] = newValue }
    }
}
