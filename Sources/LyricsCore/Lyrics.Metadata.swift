//
//  Lyrics.Metadata.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Lyrics {
    
    public struct Metadata {
        
        private var data: [Key: Any]
        
        public init(_ data: [Key: Any] = [:]) {
            self.data = data
        }
        
        public subscript(key: Key) -> Any? {
            get {
                return data[key]
            }
            set {
                data[key] = newValue
            }
        }
        
        public struct Key: RawRepresentable, Hashable {
            
            public var rawValue: String
            
            public init(_ rawValue: String) {
                self.rawValue = rawValue
            }
            
            public init(rawValue: String) {
                self.rawValue = rawValue
            }
        }
    }
}

extension Lyrics.Metadata: CustomStringConvertible {
    
    public var description: String {
        return Mirror(reflecting: self).children.map { "[\($0!):\($1)]" }.joined(separator: "\n")
    }
}

extension Lyrics.Metadata.Key {
    public static var attachmentTags = Lyrics.Metadata.Key("attachmentTags")
}

extension Lyrics.Metadata {
    
    public var attachmentTags: Set<LyricsLine.Attachments.Tag> {
        get { return data[.attachmentTags] as? Set<LyricsLine.Attachments.Tag> ?? [] }
        set { data[.attachmentTags] = newValue }
    }
    
    public var hasTranslation: Bool {
        return attachmentTags.contains(where: \.isTranslation)
    }
}
