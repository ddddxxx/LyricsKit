//
//  LyricsSearchTask.swift
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

public class LyricsSearchTask {
    
    public let request: LyricsSearchRequest
    public let progress: Progress
    
    var subTasks: [DistributedLyricsSearchTask]
    
    var timeoutTimer: Timer?
    var progressObservation: NSKeyValueObservation?
    
    init(request: LyricsSearchRequest, subTasks: [DistributedLyricsSearchTask]) {
        self.request = request
        self.subTasks = subTasks
        progress = Progress(totalUnitCount: Int64(subTasks.count))
        subTasks.forEach { progress.addChild($0.progress, withPendingUnitCount: 1) }
    }
    
    public func resume() {
        timeoutTimer = Timer.scheduledTimer(timeInterval: request.timeout, target: self, selector: #selector(cancel), userInfo: nil, repeats: false)
        progressObservation = progress.observe(\.isFinished, options: [.new]) { [weak self] progress, change in
            if change.newValue == true {
                self?.timeoutTimer?.invalidate()
            }
        }
        subTasks.forEach { $0.resume() }
    }
    
    @objc public func cancel() {
        progressObservation?.invalidate()
        progress.cancel()
    }
}

