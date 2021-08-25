//
//  Lyrics.IDTag.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Lyrics {
    
    /// Overall timestamp adjustment in milliseconds.
    ///
    /// This value is stored as ID tag in `offset` field.
    public var offset: Int {
        get {
            return idTags[.offset].flatMap { Int($0) } ?? 0
        }
        set {
            idTags[.offset] = "\(newValue)"
        }
    }
    
    /// Overall timestamp adjustment in seconds.
    public var timeDelay: TimeInterval {
        get {
            return TimeInterval(offset) / 1000
        }
        set {
            offset = Int(newValue * 1000)
        }
    }
    
    /// Length of the song.
    ///
    /// This value is stored as ID tag in `length` field.
    public var length: TimeInterval? {
        get {
            guard let len = idTags[.length],
                let match = base60TimeRegex.firstMatch(in: len) else {
                    return nil
            }
            let min = (match[1]?.content).flatMap(Double.init) ?? 0
            let sec = Double(match[2]!.content) ?? 0
            return min * 60 + sec
        }
        set {
            guard let newValue = newValue else {
                idTags.removeValue(forKey: .length)
                return
            }
            let fmt = NumberFormatter()
            fmt.minimumFractionDigits = 0
            fmt.maximumFractionDigits = 2
            let str = fmt.string(from: newValue as NSNumber)
            idTags[.length] = str
        }
    }
}

extension Lyrics {
    
    public struct IDTagKey: RawRepresentable, Hashable {
        
        public var rawValue: String
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        /// Title of the song.
        public static let title = IDTagKey("ti")
        
        /// Album of the song.
        public static let album = IDTagKey("al")
        
        /// Artist of the song.
        public static let artist = IDTagKey("ar")
        
        /// Lyricist of the song.
        public static let author = IDTagKey("au")
        
        /// Creator of the lyrics file.
        public static let lrcBy = IDTagKey("by")
        
        /// Overall timestamp adjustment in milliseconds
        public static let offset = IDTagKey("offset")
        
        /// Length of the song.
        public static let length = IDTagKey("length")
    }
}

extension Lyrics.IDTagKey: CustomStringConvertible {
    
    public var description: String {
        return rawValue
    }
}
