# SoundPlayer
🔊Super simple, low-latency sound player.

This Swift packages is currently being used in one of my apps — [Pasty — Smart Clipboard Manager](https://apps.apple.com/de/app/pasty-smart-clipboard/id1544620654?l=en&mt=12). Feel free to check it out 😉

## How to use

```
0. Add SoundPlayer Swift package to your app.

import Cocoa

// 1. Import SoundPlayer module
import SoundPlayer

// 2. Define sound identifiers
extension AudioFileIdentifier {
    static let copySound = "copySound"
    static let pasteSound = "pasteSound"
}

class ViewController: NSViewController {
    let soundPlayer = SoundPlayer.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerAudioFiles()
    }
    
    // 3. Register sound files for identifiers, defined above
    private func registerAudioFiles() {
        let audioFiles = [
            AudioFile(name: "copy", extension: "mp3", identifier: .copySound),
            AudioFile(name: "paste", extension: "mp3", identifier: .pasteSound)
        ]
        
        do {
            for audioFile in audioFiles {
                try soundPlayer.register(audioFile: audioFile)
            }
        } catch {
            print("Error registering audio file. \(error.localizedDescription)")
        }
    }
    
    // 4. Play the sound by it's identifier
    @IBAction func onPlayCopy(_ sender: Any) {
        try? soundPlayer.playFileWithIdentifier(.copySound)
    }
    
    @IBAction func onPlayPaste(_ sender: Any) {
        try? soundPlayer.playFileWithIdentifier(.pasteSound)
    }
}
```
