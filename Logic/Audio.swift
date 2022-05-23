// NoteFlier
// Copyright (C) 2022 ItsTheGuy
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import AVFoundation
import SwiftUI

class Audio {
    static let twoPi = (2*Float.pi)
    static let maxFrequency: Float = 560
    static let minFrequency: Float = 20.6
    
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
    private var postSource: AVAudioUnitEQ
    private var mixer: AVAudioMixerNode
    public var sampleRate: Float
    private var inputFormat: AVAudioFormat
    private var outputFormat: AVAudioFormat
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
    
    public var isRecording: Binding<Bool>? = nil
    public var endRecordingEvent: () -> Void = {}
    
    private var liveRecordingShared: Data.Recording.Constructor? = nil
    
    init() {
        postSource = AVAudioUnitEQ(numberOfBands: 1)
        mixer = engine.mainMixerNode
        outputFormat = engine.outputNode.inputFormat(forBus: 0)
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
        engine.attach(postSource)
        engine.attach(AUReverb)
        engine.attach(AUDelay)
        // engine.attach(AUDistorsion)
        engine.attach(AUeQ)
        engine.connect(audioSource, to: postSource, format: inputFormat)
        engine.connect(postSource, to: AUReverb, format: inputFormat)
        engine.connect(AUReverb, to: AUDelay, format: outputFormat)
        engine.connect(AUDelay, to: AUeQ, format: outputFormat)
        // engine.connect(AUDistorsion, to: nil, format: outputFormat)
        engine.connect(AUeQ, to: mixer, format: outputFormat)
        engine.connect(mixer, to: engine.outputNode, format: outputFormat)
        mixer.outputVolume = 0.25
        postSource.globalGain = 0
        try! engine.start()
        Utils.log("Audio Engine started!")
    }
    
    public func resume() {
        postSource.globalGain = 0
    }
    
    public func pause() {
        postSource.globalGain = -96
    }
    
    public func setReverb(_ effect: Data.AudioEffects.Reverb) {
        Utils.log("Reverb filter will be adjusted... \(effect)")
        AUReverb.wetDryMix = effect.wetDryMix
    }
    
    public func setDelay(_ effect: Data.AudioEffects.Delay) {
        Utils.log("Delay filter will be adjusted... \(effect)")
        AUDelay.delayTime = effect.delayTime
        AUDelay.feedback = effect.feedback
        AUDelay.lowPassCutoff = effect.lowPassCutoff
        AUDelay.wetDryMix = effect.wetDryMix
    }
    
    public func setDistorsion(_ effect: Data.AudioEffects.Distorsion) {
        Utils.log("Distorsion filter will be adjusted... \(effect)")
        AUDistorsion.preGain = effect.preGain
        AUDistorsion.wetDryMix = effect.wetDryMix
    }
    
    public func setEQ(_ effect: Data.AudioEffects.EQ.Main) {
        Utils.log("EQ filter will be adjusted... \(effect)")
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
    
    public func record() {
        Utils.log("Recording will start...")
        self.isRecording?.wrappedValue = true
        var outFile: AVAudioFile?
        let outFilename = ("NewLoop at \(Date.now.formatted(date: .complete, time: .standard))")
        let outUrl = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL).appendingPathComponent(outFilename.appending("_\(UUID.init().uuidString).m4a"))
        let outDirExists = try? outUrl!.deletingLastPathComponent().checkResourceIsReachable()
        if outDirExists != nil {
            liveRecordingShared = Data.Recording.Constructor(name2Show: outFilename, path: outUrl!)
            var outputFormatSettings = mixer.outputFormat(forBus: 0).settings
            outputFormatSettings[AVLinearPCMIsNonInterleaved] = false
            outFile = try! AVAudioFile(forWriting: outUrl!, settings: outputFormatSettings)
            mixer.installTap(onBus: 0, bufferSize: 1024, format: mixer.outputFormat(forBus: 0)) { buffer, _ in
                try? outFile?.write(from: buffer)
            }
        }
    }
    
    public func setRecordingPointer(_ recordingUpdater: Binding<Bool>) {
        self.isRecording = recordingUpdater
    }
        
    public func killRecording() {
        Utils.log("Recording will end...")
        self.engine.mainMixerNode.removeTap(onBus: 0)
        self.isRecording?.wrappedValue = false
        if let recording = liveRecordingShared { Data.Recording.Operations.saveRecording(recording) }
        self.endRecordingEvent()
    }
    
    public func stopEngine() {
        self.engine.stop()
    }

    private func phase() -> Float {
        return ((Audio.twoPi/sampleRate)*frequency)
    }
}
