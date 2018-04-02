//
//  LyricsLineAttachmentTag.swift
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

public struct LyricsLineAttachmentTag: RawRepresentable, Equatable, Hashable {
    
    public var rawValue: String
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(rawValue: String) {
        self.init(rawValue)
    }
    
    public static let translation: LyricsLineAttachmentTag = "tr"
    public static let timetag: LyricsLineAttachmentTag = "tt"
    public static let furigana: LyricsLineAttachmentTag = "fu"
    public static let romaji: LyricsLineAttachmentTag = "ro"
    
    public static func translation(languageCode: String) -> LyricsLineAttachmentTag {
        if languageCode.isEmpty {
            return .init("tr")
        } else {
            return .init("tr:" + languageCode)
        }
    }
}

extension LyricsLineAttachmentTag: CustomStringConvertible {
    
    public var description: String {
        return rawValue
    }
}

extension LyricsLineAttachmentTag: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
}
