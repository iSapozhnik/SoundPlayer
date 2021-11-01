import Cocoa
import AVFoundation

public enum SoundPlayerError: Error {
    case fileNotFound(String)
    case invalidIdentifier(String)
    case coundNotPlayAudioFile(String)
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
        case .invalidIdentifier(let identifier):
            return NSLocalizedString("Invalid audio file identifier: \(identifier)", comment: "")
        case .coundNotPlayAudioFile(let fileName):
            return NSLocalizedString("Could not play file \(fileName).", comment: "")
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
    typealias AudioFileAndPlayer = (file: AudioFile, player: AVAudioPlayer)
    
    public static let shared = SoundPlayer()
    public var isSoundOn: Bool = true
    public var volume: Float {
        get { _volume }
        set { _volume = min(1.0, max(0.0, _volume)) }
    }
    
    private var _volume: Float = 1.0 {
        didSet {
            concurrentQueue.sync {
                files.values.forEach { $0.player.volume = _volume }
            }
        }
    }
    
    private var files = [AudioFileIdentifier: AudioFileAndPlayer]()
    private let concurrentQueue = DispatchQueue(label: "SoundPlayer Files Barrier Queue", attributes: .concurrent)
    
    private init() {}
    
    public func register(audioFile: AudioFile, fromBundle bundle: Bundle = Bundle.main) throws {
        if let url = bundle.url(forResource: audioFile.name, withExtension: audioFile.extension.rawValue) {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = _volume
            didFinishLoadingAudioPlayer((file: audioFile, player: player), identifier: audioFile.identifier)
        } else {
            throw SoundPlayerError.fileNotFound(audioFile.name)
        }
    }
    
    public func playFileWithIdentifier(_ fileIdentifier: AudioFileIdentifier) throws {
        guard isSoundOn else { return }
        
        let audioFileAndPlayer = try audioFileAndPlayer(for: fileIdentifier)
        guard !audioFileAndPlayer.player.isPlaying else { return }
        if !audioFileAndPlayer.player.play() {
            throw SoundPlayerError.coundNotPlayAudioFile(audioFileAndPlayer.file.name)
        }
    }
    
    private func didFinishLoadingAudioPlayer(_ audioFileAndPlayer: AudioFileAndPlayer, identifier: AudioFileIdentifier) {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            self?.files[identifier] = audioFileAndPlayer
        }
    }
    
    private func audioFileAndPlayer(for idenfifier: AudioFileIdentifier) throws -> AudioFileAndPlayer {
        try concurrentQueue.sync {
            guard let audioFileAndPlayer = self.files[idenfifier] else { throw SoundPlayerError.invalidIdentifier(idenfifier) }
            return audioFileAndPlayer
        }
    }
}
