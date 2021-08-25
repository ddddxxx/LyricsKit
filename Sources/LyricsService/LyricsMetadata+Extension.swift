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
    public static var searchRequest = Lyrics.Metadata.Key("searchRequest")
    public static var remoteURL     = Lyrics.Metadata.Key("remoteURL")
    public static var artworkURL    = Lyrics.Metadata.Key("artworkURL")
    public static var service       = Lyrics.Metadata.Key("service")
    public static var serviceToken  = Lyrics.Metadata.Key("serviceToken")
    static var quality              = Lyrics.Metadata.Key("quality")
    
    static var searchIndex          = Lyrics.Metadata.Key("searchIndex")
}

extension Lyrics.Metadata {
    
    public var searchRequest: LyricsSearchRequest? {
        get { return self[.searchRequest] as? LyricsSearchRequest }
        set { self[.searchRequest] = newValue }
    }
    
    public var remoteURL: URL? {
        get { return self[.remoteURL] as? URL }
        set { self[.remoteURL] = newValue }
    }
    
    public var artworkURL: URL? {
        get { return self[.artworkURL] as? URL }
        set { self[.artworkURL] = newValue }
    }
    
    public var service: LyricsProviders.Service? {
        get { return self[.service] as? LyricsProviders.Service }
        set { self[.service] = newValue }
    }
    
    public var serviceToken: String? {
        get { return self[.serviceToken] as? String }
        set { self[.serviceToken] = newValue }
    }
    
    var quality: Double? {
        get { return self[.quality] as? Double }
        set { self[.quality] = newValue }
    }
    
    var searchIndex: Int {
        get { return self[.searchIndex] as? Int ?? 0 }
        set { self[.searchIndex] = newValue }
    }
}
