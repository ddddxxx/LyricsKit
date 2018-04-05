//
//  LyricsLineTests.swift
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

import XCTest
@testable import LyricsProvider

class LyricsLineTests: XCTestCase {
    
    func testTimeTagAttachment() {
        guard let att = LyricsLine.Attachments.WordTimeTag(timeTagAttachmentExample) else {
            XCTFail()
            return
        }
        XCTAssertEqual(att.tags.count, 8)
        XCTAssertEqual(att.durationMSec, 3250)
        XCTAssertEqual(att.description, timeTagAttachmentExample)
    }
    
    func testRangeAttributeAttachment() {
        guard let att = LyricsLine.Attachments.RangeAttribute(rangeAttributeAttachmentExample) else {
            XCTFail()
            return
        }
        XCTAssertEqual(att.attachment.count, 7)
        XCTAssertEqual(att.description, rangeAttributeAttachmentExample)
    }
}

let timeTagAttachmentExample = "<0,0><200,4><550,13><1850,16><2150,19><2650,25><2950,29><3250,31><3250>"

let rangeAttributeAttachmentExample = "<ano,0,2><ao,2,3><zameta,3,6><umi,6,7><no,7,8><kanata,8,10><de,10,11>"
