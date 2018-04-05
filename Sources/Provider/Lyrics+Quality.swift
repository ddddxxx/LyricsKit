//
//  Lyrics+Quality.swift
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

extension Lyrics {
    
    public var quality: Double {
        var quality = (artistQuality + titleQuality + durationQuality) / 3
        if metadata.attachmentTags.contains(.translation) {
            quality += 0.1
        }
        if metadata.attachmentTags.contains(.timetag) {
            quality += 0.1
        }
        return quality
    }
    
    private var artistQuality: Double {
        guard let artist = idTags[.artist] else { return 0.8 }
        switch metadata.request?.searchTerm {
        case let .info(_, searchArtist)?:
            return similarity(s1: artist, s2: searchArtist)
        case let .keyword(keyword)?:
            return similarity(s1: artist, in: keyword)
        case nil:
            return 0.8
        }
    }
    
    private var titleQuality: Double {
        guard let title = idTags[.title] else { return 0.8 }
        switch metadata.request?.searchTerm {
        case let .info(searchTitle, _)?:
            return similarity(s1: title, s2: searchTitle)
        case let .keyword(keyword)?:
            return similarity(s1: title, in: keyword)
        case nil:
            return 0.8
        }
    }
    
    private var durationQuality: Double {
        guard let duration = length,
            let searchDuration = metadata.request?.duration else {
                return 0.8
        }
        let dt = searchDuration - duration
        switch abs(dt) {
        case 0...1:
            return 1
        case 1...10:
            return 1 - (abs(dt) / 10)
        case _:
            return 0
        }
    }
}

private extension String {
    
    func distance(to other: String, substitutionCost: Int = 1, insertionCost: Int = 1, dedeletionCostl: Int = 1) -> Int {
        var d = Array(0...other.count)
        var t = 0
        for c1 in self {
            t = d[0]
            d[0] += 1
            for (i, c2) in other.enumerated() {
                let t2 = d[i+1]
                if c1 == c2 {
                    d[i+1] = t
                } else {
                    d[i+1] = Swift.min(t + substitutionCost, d[i] + insertionCost, t2 + dedeletionCostl)
                }
                t = t2
            }
        }
        return d.last!
    }
}

private func similarity(s1: String, s2: String) -> Double {
    let len = min(s1.count, s2.count)
    let diff = min(s1.distance(to: s2, insertionCost: 0), s1.distance(to: s2, dedeletionCostl: 0))
    return Double(len - diff) / Double(len)
}

private func similarity(s1: String, in s2: String) -> Double {
    let len = max(s1.count, s2.count)
    guard len > 0 else { return 1 }
    let diff = s1.distance(to: s2, insertionCost: 0)
    return Double(len - diff) / Double(len)
}
