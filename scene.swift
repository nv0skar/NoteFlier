// NoteFlier

import Foundation
import SpriteKit

class Playground: SKScene {
    private let player = SKSpriteNode(imageNamed: "Player")
    private let playerShadow = SKSpriteNode(imageNamed: "PlayerGlow")
    private let playerParticle = SKEmitterNode(fileNamed: "Trail.sks")
    private let playerLight = SKLightNode()
    
    private let obstacle = SKSpriteNode(imageNamed: "Obstacle")
    private let obstacleShadow = SKSpriteNode(imageNamed: "ObstacleGlow")
        
    private let engine = Audio()
        
    private var framesSinceLastObstacle: Int64 = 0
    
    private var framesRenderedSinceLastRateCheck: Int64 = 0
    private var determinedFramerate: Int64 = 0
    private var timer: Timer = Timer()
    
    private var spawnedObstacles: Set<SKSpriteNode> = []
    
    private var framesSinceLastCollision: Int64 = 0
        
    // private var startTouch: CGPoint? = nil
    private var touchPos: CGPoint? = nil
    
    override func sceneDidLoad() {
        self.scaleMode = .resizeFill
        self.backgroundColor = .black
    }
    
    private func checkIfObstacleIsOutOfView() {
        for obstacle in spawnedObstacles {
            if (obstacle.position.y + obstacle.frame.height) <= 0 {
                obstacle.removeFromParent()
                spawnedObstacles.remove(obstacle)
            }
        }
    }

    private func applyImpulse(_ where2: CGVector) {
        player.physicsBody?.applyImpulse(where2)
        playerParticle!.physicsBody?.applyImpulse(where2)
    }
    
    override func didSimulatePhysics() {
        let playerTrueWidth = (abs(playerShadow.frame.width-player.frame.width)+player.frame.width)
        let playerTrueHeight = (abs(playerShadow.frame.height-player.frame.height)+player.frame.height)
        if (((player.position.x-(playerTrueWidth/2))) <= 0) || ((player.position.x+(playerTrueWidth/2)) >= (self.scene?.size.width)!) {
            let newPosition = ((((player.position.x-(playerTrueWidth/2))) < 0) ? (playerTrueWidth/2):((self.scene?.size.width)!-(playerTrueWidth/2)))
            (player.position.x, playerParticle!.position.x) = (newPosition, (abs(player.position.x-playerParticle!.position.x) > 1) ? 0:newPosition)
            (player.zRotation, playerParticle!.zRotation) = (0, 0)
        } else if (CGVector(dx: (player.physicsBody?.velocity.dx)!.rounded(.towardZero), dy: 0) == CGVector(dx: 0, dy: 0)) || (((player.position.x-((sqrt(pow(playerTrueWidth, 2)+pow(playerTrueHeight, 2)))/2))) <= 0) || ((player.position.x+((sqrt(pow(playerTrueWidth, 2)+pow(playerTrueHeight, 2)))/2)) >= (self.scene?.size.width)!) {
            (player.zRotation, playerParticle!.zRotation) = (0, 0)
        } else {
            let rotation2PreApply = (((player.physicsBody?.velocity.dx)!/1000)*(-1))
            let rotation2Apply = ((abs(rotation2PreApply) > (1.3)) ? ((rotation2PreApply>0) ? (1.3):(-1.3)):rotation2PreApply)
            (player.zRotation, playerParticle!.zRotation) = (rotation2Apply, rotation2Apply)
        }
    }
    
    private func handleInput() {
        // Experimental impulse applier: applyImpulse(CGVector(dx: (((self.view?.frame.width)! <= 916) ? ((move.x-start.x)/(((self.view?.frame.width)!/(((self.view?.frame.width)! <= 526) ? 100:150)))):(move.x-player.position.x)), dy: 0))
        if let move = touchPos {
            if isTouchCompliant(touch: move, position: player.position, size: player.size) {
                if playerParticle!.particleBirthRate != 200 {
                    playerParticle!.particleBirthRate = 200
                }
                applyImpulse(CGVector(dx: (move.x - player.position.x), dy: 0))
            }
        }
    }
    
    private func isTouchCompliant(touch: CGPoint, position: CGPoint, size: CGSize) -> Bool {
        return (abs((position.x+(size.width/2))-touch.x) < (size.width*(log2(((self.view?.frame.width)!)))))
    }
    
    private func applyPhysics(object: SKNode) {
        object.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: player.frame.width, height: player.frame.height))
        object.physicsBody!.affectedByGravity = false
        object.physicsBody!.friction = 0
        object.physicsBody!.restitution = 0
        object.physicsBody!.linearDamping = 12.5
        object.physicsBody!.collisionBitMask = 0x00000000
    }
    
    private func spawnObstacle() {
        if spawnedObstacles.count == 3 { return }
        let localObstacle = obstacle.copy() as! SKSpriteNode
        let localObstaclesShadow = obstacleShadow.copy() as! SKSpriteNode
        let position = ((self.view?.frame.width)!/100)*CGFloat(Int32.random(in: 10...90))
        localObstacle.size = CGSize(width: 128, height: 128)
        localObstacle.position = CGPoint(x: position, y: ((self.view?.frame.height)! + obstacle.frame.height))
        localObstacle.setScale((((self.view?.frame.width)! <= 512) ? 0.55:0.8))
        localObstacle.lightingBitMask = 0x1
        localObstacle.shadowCastBitMask = 0x1
        localObstaclesShadow.size = CGSize(width: (localObstacle.size.width*2), height: (localObstacle.size.height*2))
        localObstaclesShadow.zPosition = -1
        localObstaclesShadow.alpha = 0.75
        localObstacle.run(SKAction.moveTo(y: (-obstacle.frame.height), duration: TimeInterval((((self.scene?.size.height)!/1228)*CGFloat.random(in: (4.5)...(4.75))))))
        spawnedObstacles.insert(localObstacle)
        localObstacle.addChild(localObstaclesShadow)
        self.addChild(localObstacle)
    }
        
    override func didChangeSize(_ oldSize: CGSize) {
        guard let _ = self.view else { return }
        player.position = CGPoint(x: player.position.x, y: (((self.view?.frame.width)! <= 512) ? ((self.view?.frame.midY)!*0.45):((self.view?.frame.midY)!*0.75)))
        player.setScale((((self.view?.frame.width)! <= 512) ? 0.55:0.8))
        playerParticle!.setScale((((self.view?.frame.width)! <= 512) ? 0.55:0.8))
        for obstacle in spawnedObstacles {
            obstacle.setScale((((self.view?.frame.width)! <= 512) ? 0.55:0.8))
        }
    }
    
    private func addLight(parent: SKNode) {
        playerLight.categoryBitMask = 0x1
        playerLight.ambientColor = .white
        playerLight.lightColor = .white
        playerLight.shadowColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        playerLight.falloff = 0.05
        (playerLight.lightColor, playerLight.ambientColor) = (generateRandomColor(), generateRandomColor())
        parent.addChild(playerLight)
    }
    
    private func addGlow(parent: SKNode) -> SKSpriteNode {
        let effectNode = SKEffectNode()
        let effectSprite = SKSpriteNode()
        effectSprite.color = SKColor(.purple)
        effectSprite.colorBlendFactor = 1
        effectNode.shouldRasterize = true
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius":4])
        parent.addChild(effectNode)
        effectNode.addChild(effectSprite)
        return effectSprite
    }
    
    private func addPlayer(parent: SKNode) {
        player.size = CGSize(width: 128, height: 128)
        player.position = CGPoint(x: (self.view?.frame.midX)!, y: (((self.view?.frame.width)! <= 512) ? ((self.view?.frame.midY)!*0.45):((self.view?.frame.midY)!*0.75)))
        player.setScale((((self.view?.frame.width)! <= 512) ? 0.55:0.8))
        player.zPosition = 2
        applyPhysics(object: player)
        addLight(parent: player)
        playerShadow.size = CGSize(width: (player.size.width*2), height: (player.size.height*2))
        playerShadow.zPosition = -1
        playerShadow.alpha = 0.75
        player.addChild(playerShadow)
        parent.addChild(player)
    }
    
    private func addTrail(parent: SKNode) {
        playerParticle!.targetNode = self
        playerParticle!.zPosition = 1
        playerParticle!.particleBirthRate = 0
        (playerParticle!.particleColor, playerParticle!.particleColorSequence) = generateColor4Particle()
        applyPhysics(object: playerParticle!)
        parent.addChild(playerParticle!)
    }
    
    @objc func aSecondPassed(){
        determinedFramerate = Int64(framesRenderedSinceLastRateCheck)
        framesRenderedSinceLastRateCheck = 0
    }
    
    private func countFramerate() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(aSecondPassed), userInfo: nil, repeats: true)
    }
    
    override func didMove(to view: SKView) {
        engine.start()
        addPlayer(parent: self)
        addTrail(parent: player)
        countFramerate()
    }
    
    private func setFrequency(_ xAxisOffset: CGFloat) {
        engine.setFrequency((Float(xAxisOffset)*(Float(abs(Audio.maxFrequency-Audio.minFrequency))/Float((self.scene?.frame.width)!))))
    }
    
    private func setWave(_ waveType: @escaping (Float) -> Float) {
        engine.setWave(waveType)
    }
    
    private func setAmplitude(_ ampl: Float) {
        engine.setAmplitude(ampl)
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPos = touches.first!.location(in: self)
        if isTouchCompliant(touch: touchPos!, position: player.position, size: player.size) {
            playerParticle!.particleBirthRate = 200
            setFrequency(touchPos!.x)
            engine.resume()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPos = touches.first!.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerParticle!.particleBirthRate = 0
        touchPos = nil
        engine.pause()
    }
    
    private func seconds2Frames(_ seconds: Float64) -> Int64 {
        return Int64(seconds*Float64(determinedFramerate))
    }
    
    private func frames2Seconds(_ frames: Int64) -> Float64 {
        if determinedFramerate > 0 {
            return Float64(frames/determinedFramerate)
        }
        return 0
    }
    
    private func frameCountingRoutines() {
        framesRenderedSinceLastRateCheck += 1
        framesSinceLastObstacle += 1
        framesSinceLastCollision += 1
    }
    
    private func generateRandomColor() -> SKColor {
        return SKColor(red: (CGFloat.random(in: 0...255))/255.0, green: (CGFloat.random(in: 0...255))/255.0, blue: (CGFloat.random(in: 0...255))/255.0, alpha: 1.0)
    }
    
    private func generateRandomColorSequence() -> SKKeyframeSequence {
        return SKKeyframeSequence(keyframeValues: [generateRandomColor(), generateRandomColor(), generateRandomColor(), generateRandomColor(), generateRandomColor()], times: [0, 0.25, 0.5, 0.75, 1])
    }
    
    private func generateColor4Particle() -> (SKColor, SKKeyframeSequence) {
        var particleColor = generateRandomColor()
        var particleColorSequence = generateRandomColorSequence()
        while (particleColor == playerParticle?.particleColor) && (particleColorSequence == playerParticle?.particleColorSequence) {
            particleColor = generateRandomColor()
            particleColorSequence = generateRandomColorSequence()
        }
        return (particleColor, particleColorSequence)
    }
    
    private func haptics() {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .soft)
        impactFeedbackgenerator.impactOccurred()
    }
    
    private func collision() {
        if framesSinceLastCollision >= seconds2Frames(0.8) {
            haptics()
            (playerLight.lightColor, playerLight.ambientColor) = (generateRandomColor(), generateRandomColor())
            (playerParticle!.particleColor, playerParticle!.particleColorSequence) = generateColor4Particle()
            let randomOption = Int.random(in: 0...4)
            switch randomOption {
                case 0: setWave(Audio.waves.sine)
                case 1: setWave(Audio.waves.sawtoothUp)
                case 2: setWave(Audio.waves.sawtoothDown)
                case 3: setWave(Audio.waves.square)
                case 4: setWave(Audio.waves.triangle)
                default: setWave(Audio.waves.sine)
            }
            framesSinceLastCollision = 0
        }
    }
    
    private func detectCollision() {
        for obstacle in spawnedObstacles {
            if player.frame.intersects(obstacle.frame) {
                if framesSinceLastCollision > seconds2Frames(0.25) {
                    collision()
                    return
                }
            }
        }
    }
            
    override func update(_ currentTime: CFTimeInterval) {
        frameCountingRoutines()
        if frames2Seconds(framesSinceLastObstacle) >= 1.2 {
            framesSinceLastObstacle = 0
            spawnObstacle()
        }
        handleInput()
        detectCollision()
        checkIfObstacleIsOutOfView()
        if let move = touchPos {
            if isTouchCompliant(touch: move, position: player.position, size: player.size) {
                setFrequency(move.x)
            }
        }
    }
}
