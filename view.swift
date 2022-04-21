// NoteFlier

import Foundation
import SpriteKit
import SwiftUI

struct SceneView: View {
    var body: some View {
        SpriteView(scene: Playground())
           .ignoresSafeArea()
           .statusBar(hidden: true)
    }
}
