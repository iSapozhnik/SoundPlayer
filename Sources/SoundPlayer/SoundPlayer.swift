import Cocoa
import AVFoundation

public enum SoundPlayerError: Error {
    case fileNotFound(String)
    case couldNotLoadAudioFile(String)
    case invalidIdentifier(String)
}

public enum AudioFileExtension: String {
    case caf
    case wav
    case wave
    case bwf
    case aif
    case aiff
    case aifc
    case cdda
    case amr
    case mp3
    case au
    case snd
    case ac3
    case eac3
}

extension SoundPlayerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let fileName):
            return NSLocalizedString("File \(fileName) not found.", comment: "")
        case .couldNotLoadAudioFile(let fileURL):
            return NSLocalizedString("Could not load file at URL: \(fileURL)", comment: "")
        case .invalidIdentifier(let identifier):
            return NSLocalizedString("Invalid audio file identifier: \(identifier)", comment: "")
        }
    }
}

public typealias AudioFileIdentifier = String

public struct AudioFile {
    public init(name: String, extension: AudioFileExtension, identifier: AudioFileIdentifier) {
        self.name = name
        self.extension = `extension`
        self.identifier = identifier
    }
    
    let name: String
    let `extension`: AudioFileExtension
    let identifier: AudioFileIdentifier
}

public final class SoundPlayer {
    public static let shared = SoundPlayer()
    public var isPlaying: Bool = false
    public var isSoundOn: Bool = true
    public var volume: Float = 1.0 {
        didSet {
            node.volume = volume
        }
    }
    
    private var files = [String: AVAudioFile]()
    private let engine = AVAudioEngine()
    private let node = AVAudioPlayerNode()
    
    private init() {
        node.volume = volume
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: nil)
        try? engine.start()
    }
    
    public func register(audioFile: AudioFile, fromBundle bundle: Bundle = Bundle.main) throws {
        if let url = bundle.url(forResource: audioFile.name, withExtension: audioFile.extension.rawValue) {
            try load(sound: url, for: audioFile.identifier)
        } else {
            throw SoundPlayerError.fileNotFound(audioFile.name)
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
    }
    
    public func playFileWithIdentifier(_ fileIdentifier: AudioFileIdentifier) throws {
        guard isSoundOn else { return }
        guard !isPlaying else { return }
        
        guard let file = files[fileIdentifier] else {
            throw SoundPlayerError.invalidIdentifier(fileIdentifier)
        }
        node.scheduleFile(file, at: nil, completionCallbackType: .dataPlayedBack) { [weak self] _ in
            self?.isPlaying = false
        }

        isPlaying = true
        node.play()
    }
}
