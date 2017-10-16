//
//  Regex.swift
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

private let id3TagPattern = "^(?!\\[[+-]?\\d+:\\d+(.\\d+)?\\])\\[(.+?):(.*)\\](?=\\n|$)"
let id3TagRegex = try! NSRegularExpression(pattern: id3TagPattern, options: .anchorsMatchLines)

private let krcLinePattern = "^\\[(\\d+),(\\d+)\\](.*)"
let krcLineRegex = try! NSRegularExpression(pattern: krcLinePattern, options: .anchorsMatchLines)

private let netEaseInlineTagPattern = "\\(0,(\\d+)\\)([^(]+)(\\(0,1\\) )?"
let netEaseInlineTagRegex = try! NSRegularExpression(pattern: netEaseInlineTagPattern)

private let kugouInlineTagPattern = "<(\\d+),(\\d+),0>([^<]*)"
let kugouInlineTagRegex = try! NSRegularExpression(pattern: kugouInlineTagPattern)
