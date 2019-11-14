//
//  Lyrics+Merge.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
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
                if !transStr.isEmpty {
                    lines[index].attachments.setTranslation(transStr)
                }
                lines.formIndex(after: &index)
                translation.lines.formIndex(after: &transIndex)
            } else if lines[index].position > translation.lines[transIndex].position {
                translation.lines.formIndex(after: &transIndex)
            } else {
                lines.formIndex(after: &index)
            }
        }
        metadata.attachmentTags.insert(.translation)
    }
    
    /// merge without maching timetag
    func forceMerge(translation: Lyrics) {
        guard lines.count == translation.lines.count else {
            return
        }
        for idx in lines.indices {
            let transStr = translation.lines[idx].content
            if !transStr.isEmpty {
                lines[idx].attachments.setTranslation(transStr)
            }
        }
        metadata.attachmentTags.insert(.translation)
    }
}
