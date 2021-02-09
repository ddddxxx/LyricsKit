//
//  Lyrics+Merge.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LyricsCore

private let mergeTimetagThreshold = 0.02

extension Lyrics {
    
    func merge(translation: Lyrics) {
        var index = lines.startIndex
        var transIndex = translation.lines.startIndex
        while index < lines.endIndex, transIndex < translation.lines.endIndex {
            if abs(lines[index].position - translation.lines[transIndex].position) < mergeTimetagThreshold {
                let transStr = translation.lines[transIndex].content
                if !transStr.isEmpty, transStr != "//" {
                    lines[index].attachments[.translation()] = transStr
                }
                lines.formIndex(after: &index)
                translation.lines.formIndex(after: &transIndex)
            } else if lines[index].position > translation.lines[transIndex].position {
                translation.lines.formIndex(after: &transIndex)
            } else {
                lines.formIndex(after: &index)
            }
        }
        metadata.attachmentTags.insert(.translation())
    }
    
    /// merge without maching timetag
    func forceMerge(translation: Lyrics) {
        guard lines.count == translation.lines.count else {
            return
        }
        for idx in lines.indices {
            let transStr = translation.lines[idx].content
            if !transStr.isEmpty, transStr != "//" {
                lines[idx].attachments[.translation()] = transStr
            }
        }
        metadata.attachmentTags.insert(.translation())
    }
}
