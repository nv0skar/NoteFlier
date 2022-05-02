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
import SpriteKit
import AVFoundation

class Playground: SKScene {
    private let player = Nodes.Cursor()
    private let obstacles = Nodes.Obstacles()
    private let background = Nodes.Background()
            
    public let engine = Audio()
    
    private var touchPosition: CGPoint? = nil
    
    private var canSpawnObstacle: Bool {
        get {
            if let isRecording = engine.isRecording {
                return !isRecording.wrappedValue
            } else {
                return true
            }
        }
    }
    
    private func handleInput() {
        if let move = touchPosition {
            if Utils.Scene.Extras.touchCompliant(touch: move, position: player.cursor.position, size: player.cursor.size, frameWidth: (self.view?.frame.width)!) {
                if player.particles!.particleBirthRate != 200 {
                    player.particles!.particleBirthRate = 200
                }
                player.applyImpulse(CGVector(dx: (move.x - player.cursor.position.x), dy: 0))
            }
        }
    }
    
    private func setRandomReverb() {
        engine.setReverb(Data.AudioEffects.Reverb(wetDryMix: Float.random(in: 0...100)))
    }
    
    private func setRandomDelay() {
        engine.setDelay(Data.AudioEffects.Delay(delayTime: TimeInterval(floatLiteral: Double.random(in: 0...0.6)), feedback: Float.random(in: -100...50), lowPassCutoff: Float.random(in: -14000...16000), wetDryMix: Float.random(in: 0...100)))
    }
    
    private func setRandomDistorsion() {
        engine.setDistorsion(Data.AudioEffects.Distorsion(preGain: Float.random(in: -18...(-14)), wetDryMix: Float.random(in: 0...2)))
    }
    
    private func setRandomEQ() {
        let eqParams = Data.AudioEffects.EQ.Bands(bandwidth: Float.random(in: 0.05...1), bypass: Bool.random(), filterType: AVAudioUnitEQFilterType.init(rawValue: Int.random(in: 0...10))!, frequency: Float.random(in: Audio.maxFrequency...Audio.maxFrequency), gain: Float.random(in: -18...(-14)))
        engine.setEQ(Data.AudioEffects.EQ.Main(bands: [eqParams], globalGain: Float.random(in: -4...(0))))
    }
    
    private func setRandomWave() {
        let randomOption = Int.random(in: 0...4)
        switch randomOption {
            case 0: engine.setWave(Audio.waves.sine)
            case 1: engine.setWave(Audio.waves.sawtoothUp)
            case 2: engine.setWave(Audio.waves.sawtoothDown)
            case 3: engine.setWave(Audio.waves.square)
            case 4: engine.setWave(Audio.waves.triangle)
            default: engine.setWave(Audio.waves.sawtoothUp)
        }
    }
    
    private func setFrequency(_ xAxisOffset: CGFloat) {
        engine.setFrequency((Float(xAxisOffset)*(Float(abs(Audio.maxFrequency-Audio.minFrequency))/Float((self.scene?.frame.width)!))))
    }
    
    private func setAmplitude(_ ampl: Float) {
        engine.setAmplitude(ampl)
    }
    
    private func collision() {
        Utils.hapticImpulse(.soft)
        let lightColors = Utils.Scene.Extras.generateRandomColor(2); (player.light.lightColor, player.light.ambientColor) = (lightColors[0], lightColors[1])
        (player.particles!.particleColor, player.particles!.particleColorSequence) = player.particlesColorGenerator()
        background.redrawColor = Utils.Scene.Extras.generateRandomColor().first!
        setRandomWave()
        setRandomReverb()
        setRandomDelay()
        // setRandomDistorsion()
        setRandomEQ()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPosition = touches.first!.location(in: self)
        if Utils.Scene.Extras.touchCompliant(touch: touchPosition!, position: player.cursor.position, size: player.cursor.size, frameWidth: (self.view?.frame.width)!) {
            player.particles!.particleBirthRate = 400
            setFrequency(touchPosition!.x)
            engine.resume()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPosition = touches.first!.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.particles!.particleBirthRate = 0
        touchPosition = nil
        engine.pause()
    }
    
    override func sceneDidLoad() {
        self.scaleMode = .resizeFill
        self.backgroundColor = .black
        player.setScene(self)
        obstacles.setScene(self)
        background.setScene(self)
        Utils.log("Playground loaded!")
    }
        
    override func didMove(to view: SKView) {
        engine.start()
        player.add()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        guard let _ = self.view else { return }
        player.cursor.position = CGPoint(x: player.cursor.position.x, y: (((self.view?.frame.width)! <= 512) ? ((self.view?.frame.midY)!*0.45):((self.view?.frame.midY)!*0.75)))
        player.cursor.setScale((((self.view?.frame.width)! <= 512) ? 0.55:0.8))
        player.particles!.setScale((((self.view?.frame.width)! <= 512) ? 0.55:0.8))
        for obstacle in obstacles.obstacles {
            obstacle.setScale((((self.view?.frame.width)! <= 512) ? 0.55:0.8))
        }
    }
    
    override func didSimulatePhysics() {
        player.afterPhysicsCheck()
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        handleInput()
        if obstacles.collision(player.cursor.frame) { collision() }
        if canSpawnObstacle { obstacles.spawn() }
        if let move = touchPosition {
            if Utils.Scene.Extras.touchCompliant(touch: move, position: player.cursor.position, size: player.cursor.size, frameWidth: (self.view?.frame.width)!) {
                setFrequency(move.x)
            }
        }
        background.draw(player.cursor.position)
    }
}
