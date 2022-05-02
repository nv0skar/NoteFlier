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
import SwiftUI
import FancyScrollView

struct Recordings: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State var exportView = false
    
    let recordings = Data.Recording.Operations.getRecordings()
    
    var body: some View {
        GeometryReader { viewInfo in
            VStack {
                HStack {
                    Spacer()
                    Visuals.Views.CloseButton(whenPressed: { dismiss() })
                }
                FancyScrollView(title: "Recorded Loops", titleColor: ((colorScheme == .light) ? Color.black:Color.white), scrollUpHeaderBehavior: .parallax, scrollDownHeaderBehavior: .sticky) {
                    VStack {
                        ForEach(Array(recordings), id: \.self) { recording in
                            VStack {
                                HStack {
                                    Text("\(recording.name2Show)").bold().frame(minWidth: (viewInfo.size.width*0.4), alignment: .leading).padding([.trailing], 8)
                                    Divider()
                                    Text("\(recording.path)").font(Font.system(size: 12, design: .monospaced)).frame(maxWidth: .infinity, alignment: .leading).padding([.leading], 8)
                                }.onTapGesture() { Export.share(recording.path) }
                            }
                            if !(recording == recordings[recordings.count-1]) { Divider() }
                            }.padding([.trailing, .leading])
                        }
                    }
                }
            }
        }
}
