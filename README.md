# SoundPlayer
🔊Super simple, low-latency sound player.

## How to use

```
import Cocoa
import SoundPlayer

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
    
    private func registerAudioFiles() {
        let audioFiles = [
            AudioFile(fileName: "copy", fileExtension: "mp3", identifier: .copySound),
            AudioFile(fileName: "paste", fileExtension: "mp3", identifier: .pasteSound)
        ]
        
        do {
            for audioFile in audioFiles {
                try soundPlayer.register(audioFile: audioFile)
            }
        } catch {
            print("Error registering audio file. \(error.localizedDescription)")
        }
    }
    
    @IBAction func onPlayCopy(_ sender: Any) {
        try? soundPlayer.playFileWithIdentifier(.copySound)
    }
    
    @IBAction func onPlayPaste(_ sender: Any) {
        try? soundPlayer.playFileWithIdentifier(.pasteSound)
    }
}
```
