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

import SwiftUI

final class Delegate: UIResponder, UIApplicationDelegate {
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        for toRemove in [UIMenu.Identifier.preferences, UIMenu.Identifier.file, UIMenu.Identifier.view, UIMenu.Identifier.format, UIMenu.Identifier.edit, UIMenu.Identifier.window] {
            builder.remove(menu: toRemove)
        }
    }
}

@main
struct Main: App {
    @UIApplicationDelegateAdaptor(Delegate.self) var delegate
    
    var body: some Scene {
        WindowGroup { OrchestratorDelegate().onAppear() {
            #if (DEBUG)
            Commons.console.isVisible = true
            #endif
        }}
    }
}
