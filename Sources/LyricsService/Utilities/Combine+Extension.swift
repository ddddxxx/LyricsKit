//
//  Combine+Extension.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation
import CXShim

extension Publisher {
    
    func `catch`() -> Publishers.Catch<Self, Empty<Output, Never>> {
        return self.catch { _ in Empty() }
    }
}
