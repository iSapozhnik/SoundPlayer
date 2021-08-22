import Cocoa
import Combine
import AVFoundation

public enum SoundPlayerError: Error {
    case fileNotFound(String)
    case couldNotLoadAudioFile(String)
    case invalidIdentifier(String)
    case isPlaying
}

extension SoundPlayerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let fileName):
            return NSLocalizedString("File \(fileName) not found.", comment: "")
        case .isPlaying:
            return NSLocalizedString("AVAudioPlayer is currently playing a sound", comment: "")
        case .couldNotLoadAudioFile(let fileURL):
            return NSLocalizedString("Could not find file at URL: \(fileURL)", comment: "")
        case .invalidIdentifier(let identifier):
            return NSLocalizedString("Invalid audio file identifier: \(identifier)", comment: "")
        }
    }
}

public typealias AudioFileIdentifier = String

public struct AudioFile {
    public init(fileName: String, fileExtension: String, identifier: AudioFileIdentifier) {
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.identifier = identifier
    }
    
    let fileName: String
    let fileExtension: String
    let identifier: AudioFileIdentifier
}

public final class SoundPlayer {
    public static let shared = SoundPlayer()
    public var isPlaying: Bool = false
    public var isSoundOn: Bool = true
    
    private var files = [String: AVAudioFile]()
    private let engine = AVAudioEngine()
    private let node = AVAudioPlayerNode()
    
    private init() {
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: nil)
        try? engine.start()
    }
    
    public func register(audioFile: AudioFile, fromBundle bundle: Bundle = Bundle.main) throws {
        if let url = bundle.url(forResource: audioFile.fileName, withExtension: audioFile.fileExtension) {
            try load(sound: url, for: audioFile.identifier)
        } else {
            throw SoundPlayerError.fileNotFound(audioFile.fileName)
        }
    }
    
    private func load(sound url: URL, for identifier: AudioFileIdentifier) throws {
        do {
            let file = try AVAudioFile(forReading: url)
            didFinishLoadingAudioFile(file, identifier: identifier)
        } catch {
            throw SoundPlayerError.couldNotLoadAudioFile(url.absoluteString)
        }
    }
    
    private func didFinishLoadingAudioFile(_ file: AVAudioFile, identifier: AudioFileIdentifier) {
        files[identifier] = file
        print("didFinishLoadingAudioFile \(file.url.lastPathComponent)")
    }
    
    public func playFileWithIdentifier(_ fileIdentifier: AudioFileIdentifier) throws {
        guard isSoundOn else { return }
        guard !isPlaying else { return }
        let file = files[fileIdentifier]
        
        guard let audioFile = file else {
            throw SoundPlayerError.invalidIdentifier(fileIdentifier)
        }
        node.scheduleFile(audioFile, at: nil, completionCallbackType: .dataPlayedBack) { [weak self] callbackType in
            self?.isPlaying = false
        }

        isPlaying = true
        node.play()
    }
}
