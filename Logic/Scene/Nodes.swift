// NoteFlier
// Copyright (C) 2022 Oscar
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
import SwiftUI
import SpriteKit

class Nodes {
    class Cursor {
        public let (cursor, shadow, particles, light) = (SKSpriteNode(imageNamed: "Player"), SKSpriteNode(imageNamed: "PlayerGlow"), SKEmitterNode(fileNamed: "Trail.sks"), SKLightNode())
        
        private var scene: SKScene? = nil
        
        public func setScene(_ scene: SKScene) {
            self.scene = scene
        }
        
        private func addPhysics(_ toApply: SKNode) {
            toApply.physicsBody = SKPhysicsBody(rectangleOf: cursor.frame.size)
            toApply.physicsBody!.affectedByGravity = false
            toApply.physicsBody!.friction = 0
            toApply.physicsBody!.restitution = 0
            toApply.physicsBody!.linearDamping = 12.5
            toApply.physicsBody!.collisionBitMask = 0x00000000
        }
        
        private func addParticles() {
            particles!.targetNode = self.scene
            particles!.zPosition = 1
            particles!.particleBirthRate = 0
            (particles!.particleColor, particles!.particleColorSequence) = particlesColorGenerator()
            addPhysics(particles!)
            cursor.addChild(particles!)
        }
        
        private func addLight() {
            light.categoryBitMask = 0x1
            light.ambientColor = .white
            light.lightColor = .white
            light.shadowColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.05)
            light.falloff = 0.05
            let lightColors = Utils.Scene.Extras.generateRandomColor(2); (light.lightColor, light.ambientColor) = (lightColors[0], lightColors[1])
            cursor.addChild(light)
        }
        
        private func addShadow() {
            shadow.size = CGSize(width: (cursor.size.width*(((scene!.view?.frame.width)! <= 512) ? 2.25:1.5)), height: (cursor.size.height*(((scene!.view?.frame.width)! <= 512) ? 2.25:1.5)))
            shadow.zPosition = -1
            shadow.alpha = 0.75
            cursor.addChild(shadow)
        }
        
        public func add() {
            cursor.size = CGSize(width: 128, height: 128)
            cursor.position = CGPoint(x: (scene!.view?.frame.midX)!, y: (((scene!.view?.frame.width)! <= 512) ? ((scene!.view?.frame.midY)!*0.45):((scene!.view?.frame.midY)!*0.75)))
            cursor.setScale((((scene!.view?.frame.width)! <= 512) ? 0.55:0.8))
            cursor.zPosition = 2
            addLight()
            addShadow()
            addParticles()
            addPhysics(cursor)
            self.scene!.addChild(cursor)
        }
        
        public func applyImpulse(_ where2: CGVector) {
            cursor.physicsBody?.applyImpulse(where2)
            particles!.physicsBody?.applyImpulse(where2)
        }
    }
        
    class Obstacles {
        class ObstaclePrimitive: SKSpriteNode { public var collided  = false }
        
        private let (obstacleTemplate, shadowTemplate) = (ObstaclePrimitive(imageNamed: "Obstacle"), SKSpriteNode(imageNamed: "ObstacleGlow"))
        
        public var obstacles: Set<ObstaclePrimitive> = []
        
        private var scene: SKScene? = nil
        
        public func setScene(_ scene: SKScene) {
            self.scene = scene
        }
        
        public func spawn() {
            if obstacles.count == 1 { return }
            let localObstacle = obstacleTemplate.copy() as! ObstaclePrimitive
            let localObstaclesShadow = shadowTemplate.copy() as! SKSpriteNode
            let position = ((scene!.view?.frame.width)!/100)*CGFloat(Int32.random(in: 10...90))
            localObstacle.size = CGSize(width: 128, height: 128)
            localObstacle.position = CGPoint(x: position, y: ((scene!.view?.frame.height)! + (shadowTemplate.frame.height/2)))
            localObstacle.setScale((((scene!.view?.frame.width)! <= 512) ? 0.55:0.8))
            localObstacle.zPosition = 1
            localObstacle.lightingBitMask = 0x1
            localObstacle.shadowCastBitMask = 0x1
            localObstaclesShadow.size = CGSize(width: (localObstacle.size.width*(((scene!.view?.frame.width)! <= 512) ? 2.25:1.5)), height: (localObstacle.size.height*(((scene!.view?.frame.width)! <= 512) ? 2.25:1.5)))
            localObstaclesShadow.zPosition = -1
            localObstaclesShadow.alpha = 0.75
            localObstacle.run(SKAction.moveTo(y: -(localObstaclesShadow.frame.size.height/2), duration: TimeInterval((((scene!.scene?.size.height)!/1228)*CGFloat.random(in: (1.8)...(2.0)))))) {
                localObstacle.removeFromParent()
                self.obstacles.remove(localObstacle)
            }
            localObstacle.addChild(localObstaclesShadow)
            obstacles.insert(localObstacle)
            self.scene!.addChild(localObstacle)
        }
    }
    
    class Background {
        private let background = SKNode()
        
        public var redrawColor: SKColor? = nil
        
        private var scene: SKScene? = nil
        
        public func setScene(_ scene: SKScene) {
            self.scene = scene
        }
        
        public func draw(_ cursorPosition: CGPoint) {
            background.removeAllChildren()
            background.removeFromParent()
            let lanes2Draw = 38
            let curvature = (1.02-((((cursorPosition.x)+(scene!.scene?.frame.midX)!)/(scene!.scene?.frame.midX)!)/100))
            for position in 0...lanes2Draw {
                let positionX = (((scene!.scene?.frame.width)!/CGFloat(lanes2Draw)*2)*CGFloat(position*2))
                var paths = [CGPoint(x: positionX, y: 0), CGPoint(x: pow((((scene!.scene?.frame.width)!/CGFloat(lanes2Draw)*2)*CGFloat(position*2)), curvature), y: (cursorPosition.y)), CGPoint(x: positionX, y: (self.scene?.frame.height)!)]
                let backgroundLane = SKShapeNode(splinePoints: &paths, count: 3)
                backgroundLane.position.x -= (scene!.view?.frame.width)!
                if let color = redrawColor {
                    backgroundLane.strokeColor = color
                } else {
                    redrawColor = Utils.Scene.Extras.generateRandomColor().first!
                    backgroundLane.strokeColor = redrawColor!
                }
                backgroundLane.lineWidth = 3
                backgroundLane.glowWidth = 1
                background.addChild(backgroundLane)
            }
            scene!.addChild(background)
        }
        
    }
}

extension Nodes.Cursor {
    public func particlesColorGenerator() -> (SKColor, SKKeyframeSequence) {
        var particleColor = Utils.Scene.Extras.generateRandomColor().first!
        var particleColorSequence = Utils.Scene.Extras.generateRandomColorSequence()
        while (particleColor == particles?.particleColor) && (particleColorSequence == particles?.particleColorSequence) {
            particleColor = Utils.Scene.Extras.generateRandomColor().first!
            particleColorSequence = Utils.Scene.Extras.generateRandomColorSequence()
        }
        return (particleColor, particleColorSequence)
    }
    
    public func afterPhysicsCheck() {
        let cursorTotalWidth = (abs((shadow.frame.width*(((scene!.view?.frame.width)! <= 512) ? 0.55:0.8))-cursor.frame.width)+cursor.frame.width)
        let cursorTotalHeight = (abs((shadow.frame.height*(((scene!.view?.frame.width)! <= 512) ? 0.55:0.8))-cursor.frame.height)+cursor.frame.height)
        if (((cursor.position.x-(cursorTotalWidth/2))) <= 0) || ((cursor.position.x+(cursorTotalWidth/2)) >= (scene!.scene?.size.width)!) {
            let newPosition = ((((cursor.position.x-(cursorTotalWidth/2))) <= 0) ? (cursorTotalWidth/2):((scene!.scene?.size.width)!-(cursorTotalWidth/2)))
            (cursor.position.x, particles!.position.x) = (newPosition, (abs(cursor.position.x-particles!.position.x) > 1) ? 0:newPosition)
            (cursor.zRotation, particles!.zRotation) = (0, 0)
        } else if (CGVector(dx: (cursor.physicsBody?.velocity.dx)!.rounded(.towardZero), dy: 0) == CGVector(dx: 0, dy: 0)) || (((cursor.position.x-((sqrt(pow(cursorTotalWidth, 2)+pow(cursorTotalHeight, 2)))/2))) <= 0) || ((cursor.position.x+((sqrt(pow(cursorTotalWidth, 2)+pow(cursorTotalHeight, 2)))/2)) >= (scene!.scene?.size.width)!) {
            (cursor.zRotation, particles!.zRotation) = (0, 0)
        } else {
            let rotation2PreApply = (((cursor.physicsBody?.velocity.dx)!/1000)*(-1))
            let rotation2Apply = ((abs(rotation2PreApply) > (1.3)) ? ((rotation2PreApply>0) ? (1.3):(-1.3)):rotation2PreApply)
            (cursor.zRotation, particles!.zRotation) = (rotation2Apply, rotation2Apply)
        }
    }
}

extension Nodes.Obstacles {
    public func deleteAllObstacles(){
        for obstacle in obstacles {
            obstacle.removeFromParent()
            self.obstacles.remove(obstacle)
        }
    }
    
    public func collision(_ toCheck: CGRect) -> Bool {
        for obstacle in obstacles {
            if obstacle.frame.intersects(toCheck) && !obstacle.collided {
                obstacle.collided = true
                return true
            }
        }
        return false
    }
}
