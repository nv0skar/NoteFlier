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

import SwiftUI
import SlideOverCard
import Presentation

struct OrchestratorDelegate: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var intro = !(Commons.defaults.bool(forKey: "introPresented"))
    @State private var looper = false
    @State private var recordings = false
    
    var body: some View {
        ZStack {
            Menu(intro: $intro, looper: $looper, recordings: $recordings)
        }
        .present(isPresented: $looper, transition: .crossDissolve, style: .fullScreen, content: { Looper(isPresented: $looper) })
        .present(isPresented: $recordings, content: { Recordings() })
        .present(isPresented: $intro, style: .overFullScreen, content: {
            Eggs.Intro(show: $intro)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear() {
                    if !(Commons.defaults.bool(forKey: "introPresented")) && intro {
                        Commons.defaults.set(true, forKey: "introPresented")
                    }
            }
        })
        .background(Visuals.Views.DopeBackground().background((colorScheme == .light) ? Color(red: (247/255), green: (243/255), blue: (235/255)):Color(red: (8/255), green: (12/255), blue: (20/255))))
    }
}
