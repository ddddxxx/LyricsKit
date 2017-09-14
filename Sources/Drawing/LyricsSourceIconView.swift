//
//  LyricsSourceIconView.swift
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

#if !os(watchOS)
    
    @available(OSX 10.10, iOS 8, tvOS 2, *)
    private extension Lyrics.MetaData.Source {
        
        var drawingMethod: ((CGRect) -> Void)? {
            switch self {
            // cannot infer type. Xcode sucks.
            case Lyrics.MetaData.Source.Music163:
                return LyricsSourceIconDrawing.draw_163Music
            case Lyrics.MetaData.Source.Gecimi:
                return LyricsSourceIconDrawing.drawGecimi
            case Lyrics.MetaData.Source.Kugou:
                return LyricsSourceIconDrawing.drawKugou
            case Lyrics.MetaData.Source.QQMusic:
                return LyricsSourceIconDrawing.drawQQMusic
            case Lyrics.MetaData.Source.TTPod:
                return LyricsSourceIconDrawing.drawTTPod
            case Lyrics.MetaData.Source.Xiami:
                return LyricsSourceIconDrawing.drawXiami
            default:
                return nil
            }
        }
        
    }
    
#endif

#if os(macOS)
    
    import Cocoa
    
    @IBDesignable
    public class LyricsSourceIconView: NSView {
        
        public var source: Lyrics.MetaData.Source = .Unknown
        
        public override func draw(_ dirtyRect: NSRect) {
            super.draw(dirtyRect)
            if let context = NSGraphicsContext.current?.cgContext {
                context.translateBy(x: 0, y: frame.height)
                context.scaleBy(x: 1, y: -1)
            }
            source.drawingMethod?(frame)
        }
        
    }
    
#elseif os(iOS) || os(tvOS)
    
    import UIKit
    
    @IBDesignable
    public class LyricsSourceIconView: UIView {
        
        @IBInspectable
        public var source: Lyrics.MetaData.Source = .Unknown
        
        public override func draw(_ rect: CGRect) {
            super.draw(rect)
            source.drawingMethod?(frame)
        }
        
    }

#endif
