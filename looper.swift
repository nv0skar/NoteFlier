// NoteFlier

import Foundation
import SpriteKit
import SwiftUI

struct Looper: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        SpriteView(scene: Playground())
            .ignoresSafeArea()
            .statusBar(hidden: true)
    }
}
