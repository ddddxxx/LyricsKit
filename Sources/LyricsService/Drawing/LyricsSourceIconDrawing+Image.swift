//
//  LyricsSourceIconDrawing+Image.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if canImport(CoreGraphics)

import CoreGraphics

@available(OSX 10.10, iOS 8, tvOS 2, *)
private extension LyricsProviders.Service {
    
    var drawingMethod: ((CGRect) -> Void)? {
        switch self {
        case .netease:
            return LyricsSourceIconDrawing.drawNetEaseMusic
        case .gecimi:
            return LyricsSourceIconDrawing.drawGecimi
        case .kugou:
            return LyricsSourceIconDrawing.drawKugou
        case .qq:
            return LyricsSourceIconDrawing.drawQQMusic
        default:
            return nil
        }
    }
    
}

#endif

#if canImport(Cocoa)
    
import Cocoa

extension LyricsSourceIconDrawing {
    
    public static let defaultSize = CGSize(width: 48, height: 48)
    
    public static func icon(of service: LyricsProviders.Service, size: CGSize = defaultSize) -> NSImage {
        return NSImage(size: size, flipped: false) { (NSRect) -> Bool in
            service.drawingMethod?(CGRect(origin: .zero, size: size))
            return true
        }
    }
}
    
#elseif canImport(UIKit)
    
import UIKit

extension LyricsSourceIconDrawing {
    
    public static let defaultSize = CGSize(width: 48, height: 48)
    
    public static func icon(of service: LyricsProviders.Service, size: CGSize = defaultSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        service.drawingMethod?(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

#endif
