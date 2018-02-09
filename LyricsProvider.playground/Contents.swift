import Cocoa
import LyricsProvider
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let title = "Uprising"
let artist = "Muse"
let duration = 305.0

let lpm = LyricsProviderManager()
let req = LyricsSearchRequest(searchTerm: .info(title: title, artist: artist), title: title, artist: artist, duration: 305)

var result: [Lyrics] = []

var task: LyricsSearchTask!
task = lpm.searchLyrics(request: req) { lrc in
    result.append(lrc)
}

var kvo: NSKeyValueObservation?
kvo = task.progress.observe(\.isFinished, options: [.new]) { progress, change in
    if change.newValue == true {
        kvo?.invalidate()
        // searchComplete
        
        result
        
        PlaygroundPage.current.finishExecution()
    }
}

//task.resume()

