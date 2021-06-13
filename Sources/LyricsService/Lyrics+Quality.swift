//
//  Lyrics+Quality.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LyricsCore

private let translationBonus = 0.1
private let inlineTimeTagBonus = 0.1
private let matchedArtistFactor = 1.3
private let matchedTitleFactor = 1.5
private let noArtistFactor = 0.8
private let noTitleFactor = 0.8
private let noDurationFactor = 0.8
private let minimalDurationQuality = 0.5
private let qualityMixBound = 1.05

extension Lyrics {
    
    public var quality: Double {
        if let quality = metadata.quality {
            return quality
        }
        var quality = 1 - pow((qualityMixBound - artistQuality) * (qualityMixBound - titleQuality) * (qualityMixBound - durationQuality), 0.3333)
        if metadata.hasTranslation {
            quality += translationBonus
        }
        if metadata.attachmentTags.contains(.timetag) {
            quality += inlineTimeTagBonus
        }
        metadata.quality = quality
        return quality
    }
    
    public func isMatched() -> Bool {
        guard let artist = idTags[.artist],
            let title = idTags[.title] else {
            return false
        }
        switch metadata.request?.searchTerm {
        case let .info(searchTitle, searchArtist)?:
            return title.isCaseInsensitiveSimilar(to: searchTitle)
                && artist.isCaseInsensitiveSimilar(to: searchArtist)
        case let .keyword(keyword)?:
            return title.isCaseInsensitiveSimilar(to: keyword)
                && artist.isCaseInsensitiveSimilar(to: keyword)
        case nil:
            return false
        }
    }
    
    private var artistQuality: Double {
        guard let artist = idTags[.artist] else { return noArtistFactor }
        switch metadata.request?.searchTerm {
        case let .info(_, searchArtist)?:
            if artist == searchArtist { return matchedArtistFactor }
            return similarity(s1: artist, s2: searchArtist)
        case let .keyword(keyword)?:
            if keyword.contains(artist) { return matchedArtistFactor }
            return similarity(s1: artist, in: keyword)
        case nil:
            return noArtistFactor
        }
    }
    
    private var titleQuality: Double {
        guard let title = idTags[.title] else { return noTitleFactor }
        switch metadata.request?.searchTerm {
        case let .info(searchTitle, _)?:
            if title == searchTitle { return matchedTitleFactor }
            return similarity(s1: title, s2: searchTitle)
        case let .keyword(keyword)?:
            if keyword.contains(title) { return matchedTitleFactor }
            return similarity(s1: title, in: keyword)
        case nil:
            return noTitleFactor
        }
    }
    
    private var durationQuality: Double {
        guard let duration = length,
            let searchDuration = metadata.request?.duration else {
                return noDurationFactor
        }
        let dt = searchDuration - duration
        guard dt < 10 else {
            return minimalDurationQuality
        }
        return 1 - pow(1 - (dt / 10), 2) * (1 - minimalDurationQuality)
    }
}

private extension String {
    
    func distance(to other: String, substitutionCost: Int = 1, insertionCost: Int = 1, deletionCost: Int = 1) -> Int {
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
                    d[i+1] = Swift.min(t + substitutionCost, d[i] + insertionCost, t2 + deletionCost)
                }
                t = t2
            }
        }
        return d.last!
    }
    
    func isCaseInsensitiveSimilar(to string: String) -> Bool {
        let s1 = lowercased()
        let s2 = string.lowercased()
        return s1.contains(s2) || s2.contains(s1)
    }
}

private func similarity(s1: String, s2: String) -> Double {
    let len = min(s1.count, s2.count)
    let diff = min(s1.distance(to: s2, insertionCost: 0), s1.distance(to: s2, deletionCost: 0))
    return Double(len - diff) / Double(len)
}

private func similarity(s1: String, in s2: String) -> Double {
    let len = max(s1.count, s2.count)
    guard len > 0 else { return 1 }
    let diff = s1.distance(to: s2, insertionCost: 0)
    return Double(len - diff) / Double(len)
}
