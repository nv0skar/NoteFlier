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
import LocalConsole

class Commons {
    static let db = Database()
    static let defaults = UserDefaults.standard
    static let console = LCManager.shared
}

class Fixed {
    class Eggs {
        class Intro {
            static let title = "✨ New around here? ✨"
            static let subtitle = "This app is called NoteFlier a fancy tone generator that aims to be reallistic, generate good sounds and provide musicians a tool to create random master pieces 🌈"
            static let features: [Data.Eggs.Intro] = [
                .init(icon: "questionmark.app.dashed", text: "Fine tune the effects randomly 🎹 (Reverb, Delay and EQ) (The obstacle changes their values)"),
                .init(icon: "cursorarrow.rays", text: "Export them 🛟 (Go to: Saved Loops and click the Path to export your recordings)"),
                .init(icon: "bubble.left.and.exclamationmark.bubble.right", text: "This is not yet finished as you may notice. There are features that doesn't work for more info head to the README 🐙")
            ]
        }
    }
}
