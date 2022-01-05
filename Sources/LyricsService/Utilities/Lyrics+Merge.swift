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
        var index = self.startIndex
        var transIndex = translation.startIndex
        while index < self.endIndex, transIndex < translation.endIndex {
            if abs(self[index].position - translation[transIndex].position) < mergeTimetagThreshold {
                let transStr = translation[transIndex].content
                if !transStr.isEmpty, transStr != "//" {
                    self[index].attachments[.translation()] = transStr
                }
                self.formIndex(after: &index)
                translation.formIndex(after: &transIndex)
            } else if self[index].position > translation[transIndex].position {
                translation.formIndex(after: &transIndex)
            } else {
                self.formIndex(after: &index)
            }
        }
        metadata.attachmentTags.insert(.translation())
    }
    
    /// merge without maching timetag
    func forceMerge(translation: Lyrics) {
        guard self.count == translation.count else {
            return
        }
        for idx in self.indices {
            let transStr = translation[idx].content
            if !transStr.isEmpty, transStr != "//" {
                self[idx].attachments[.translation()] = transStr
            }
        }
        metadata.attachmentTags.insert(.translation())
    }
}
