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
import UIKit
import SpriteKit

final class Utils {
    class Scene {
        class Extras {
            static func touchCompliant(touch: CGPoint, position: CGPoint, size: CGSize, frameWidth: CGFloat) -> Bool {
                return (abs((position.x+(size.width/2))-touch.x) < (size.width*(log2((frameWidth)))))
            }
            
            static func generateRandomColor(_ quantity: Int = 1) -> [SKColor] {
                var colors: [SKColor] = []
                for _ in 0...quantity {
                    colors.append(SKColor(red: (CGFloat.random(in: 0...255))/255.0, green: (CGFloat.random(in: 0...255))/255.0, blue: (CGFloat.random(in: 0...255))/255.0, alpha: 1.0))
                }; return colors
            }
            
            static func generateRandomColorSequence() -> SKKeyframeSequence {
                let colors = generateRandomColor(5)
                return SKKeyframeSequence(keyframeValues: [colors[0], colors[1], colors[2], colors[3], colors[4]], times: [0, 0.25, 0.5, 0.75, 1])
            }
        }
    }
    
    static func log(_ message: String) {
        #if (DEBUG)
        print(message); Commons.console.print(message)
        #endif
    }
    
    static func hapticImpulse(_ kind: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: kind)
        impactFeedbackgenerator.impactOccurred()
    }
}
