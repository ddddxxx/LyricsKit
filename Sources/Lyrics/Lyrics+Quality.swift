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
    
    var quality: Int {
        return 0
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
