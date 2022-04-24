// NoteFlier

import Foundation
import AVFoundation
import SwiftUI

class Audio {
    static let twoPi = (2*Float.pi)
    static let maxFrequency: Float = 440
    static let minFrequency: Float = 20.6
    static let recordDuration: Float = 6
    
    public struct waves {
        static let sine = { (phase: Float) -> Float in
            return sin(phase)
        }
        
        static let whiteNoise = { (phase: Float) -> Float in
            return ((Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX)) * 2 - 1)
        }
        
        static let sawtoothUp = { (phase: Float) -> Float in
            return 1.0 - 2.0 * (phase * (1.0 / Audio.twoPi))
        }
        
        static let sawtoothDown = { (phase: Float) -> Float in
            return (2.0 * (phase * (1.0 / Audio.twoPi))) - 1.0
        }
        
        static let square = { (phase: Float) -> Float in
            if phase <= Float.pi {
                return 1.0
            } else {
                return -1.0
            }
        }
        
        static let triangle = { (phase: Float) -> Float in
            var value = (2.0 * (phase * (1.0 / twoPi))) - 1.0
            if value < 0.0 {
                value = -value
            }
            return 2.0 * (value - 0.5)
        }
    }
    
    private let engine = AVAudioEngine()
    private var mixer: AVAudioMixerNode
    private var output: AVAudioOutputNode
    private var outputFormat: AVAudioFormat
    public var sampleRate: Float
    private var inputFormat: AVAudioFormat
    private var audioSource: AVAudioNode = AVAudioNode()
    private var currentPhase: Float = 0
    
    private var frequency: Float = 0
    private var amplitude: Float = 1
    private var wave: (Float) -> Float = waves.sine
    
    private var AUReverb: AVAudioUnitReverb
    private var AUDelay: AVAudioUnitDelay
    private var AUDistorsion: AVAudioUnitDistortion
    private var AUeQ: AVAudioUnitEQ
    
    private var reverb: Data.AudioEffects.Reverb = .init(wetDryMix: 0)
    private var delay: Data.AudioEffects.Delay = .init(delayTime: TimeInterval(floatLiteral: 0), feedback: 0, lowPassCutoff: 0, wetDryMix: 0)
    private var distorsion: Data.AudioEffects.Distorsion = .init(preGain: 0, wetDryMix: 0)
    private var eq: Data.AudioEffects.EQ.Main = .init(bands: [], globalGain: 0)
    
    private var isRecording: Binding<Bool>? = nil
    public var endRecordingEvent: () -> Void = {}
    
    init() {
        mixer = engine.mainMixerNode
        output = engine.outputNode
        outputFormat = output.inputFormat(forBus: 0)
        sampleRate = Float(outputFormat.sampleRate)
        inputFormat = AVAudioFormat(commonFormat: outputFormat.commonFormat, sampleRate: outputFormat.sampleRate, channels: 1, interleaved: outputFormat.isInterleaved)!
        AUReverb = AVAudioUnitReverb()
        AUDelay = AVAudioUnitDelay()
        AUDistorsion = AVAudioUnitDistortion()
        AUeQ = AVAudioUnitEQ(numberOfBands: 1)
        audioSource = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let phaseIncrement = self.phase()
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
                let value = self.wave(self.currentPhase) * self.amplitude
                self.currentPhase += phaseIncrement
                if self.currentPhase >= Audio.twoPi {
                    self.currentPhase -= Audio.twoPi
                }
                if self.currentPhase < 0.0 {
                    self.currentPhase += Audio.twoPi
                }
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = value
                }
            }
            return noErr
        }
    }
    
    public func start() {
        engine.attach(audioSource)
        // engine.connect(AUReverb, to: audioSource, format: inputFormat)
        // engine.connect(AUDelay, to: audioSource, format: inputFormat)
        // engine.connect(AUDistorsion, to: audioSource, format: inputFormat)
        // engine.connect(AUeQ, to: audioSource, format: inputFormat)
        engine.connect(audioSource, to: mixer, format: inputFormat)
        engine.connect(mixer, to: output, format: outputFormat)
        mixer.outputVolume = 0
        try! engine.start()
    }
    
    public func resume() {
        mixer.outputVolume = 0.25
    }
    
    public func pause() {
        mixer.outputVolume = 0
    }
    
    public func setReverb(_ effect: Data.AudioEffects.Reverb) {
        AUReverb.wetDryMix = effect.wetDryMix
    }
    
    public func setDelay(_ effect: Data.AudioEffects.Delay) {
        AUDelay.delayTime = effect.delayTime
        AUDelay.feedback = effect.feedback
        AUDelay.lowPassCutoff = effect.lowPassCutoff
        AUDelay.wetDryMix = effect.wetDryMix
    }
    
    public func setDistorsion(_ effect: Data.AudioEffects.Distorsion) {
        AUDistorsion.preGain = effect.preGain
        AUDistorsion.wetDryMix = effect.wetDryMix
    }
    
    public func setEQ(_ effect: Data.AudioEffects.EQ.Main) {
        let eqPams: AVAudioUnitEQFilterParameters = AUeQ.bands.first! as AVAudioUnitEQFilterParameters
        let _ = eqPams
        eqPams.frequency = effect.bands.first!.frequency
        eqPams.filterType = effect.bands.first!.filterType
        eqPams.gain = effect.bands.first!.gain
        eqPams.bypass = effect.bands.first!.bypass
        AUeQ.globalGain = effect.globalGain
    }
    
    public func setWave(_ waveType: @escaping (Float) -> Float) {
        wave = waveType
    }
    
    public func setFrequency(_ freq: Float) {
        frequency = (((freq<Audio.minFrequency) ? Audio.minFrequency:((freq>Audio.maxFrequency) ? Audio.maxFrequency:freq))+abs(Audio.maxFrequency-Audio.minFrequency))
    }
    
    public func setAmplitude(_ ampl: Float) {
        amplitude = ((ampl<1) ? ((ampl<0) ? 0:ampl):1)
    }
    
    public func record(_ duration: Float = Audio.recordDuration) {
        self.isRecording?.wrappedValue = true
        var outFile: AVAudioFile?
        var samplesWritten: AVAudioFrameCount = 0
        let outFilename = String(UUID.init().uuidString)
        let outUrl = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL).appendingPathComponent(outFilename.appending(".m4a"))
        let outDirExists = try? outUrl!.deletingLastPathComponent().checkResourceIsReachable()
        if outDirExists != nil {
            var outputFormatSettings = audioSource.outputFormat(forBus: 0).settings
            outputFormatSettings[AVLinearPCMIsNonInterleaved] = false
            outFile = try! AVAudioFile(forWriting: outUrl!, settings: outputFormatSettings)
            let samples2Write = AVAudioFrameCount(duration * sampleRate)
            audioSource.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { buffer, _ in
                if samplesWritten + buffer.frameLength > samples2Write {
                    buffer.frameLength = samples2Write - samplesWritten
                }
                try? outFile?.write(from: buffer)
                samplesWritten += buffer.frameLength
                if samplesWritten == samples2Write {
                    outFile = nil
                    self.audioSource.removeTap(onBus: 0)
                    self.isRecording?.wrappedValue = false
                    recordings.update(with: Data.Recording(name2Show: outFilename, path: (outUrl!)))
                    self.endRecordingEvent()
                }
            }
        }
    }
    
    public func setRecordingPointer(_ recordingUpdater: Binding<Bool>) {
        self.isRecording = recordingUpdater
    }
        
    public func killRecording() {
        self.audioSource.removeTap(onBus: 0)
        self.isRecording?.wrappedValue = false
        self.endRecordingEvent()
    }

    private func phase() -> Float {
        return ((Audio.twoPi/sampleRate)*frequency)
    }
}
