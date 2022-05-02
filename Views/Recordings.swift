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
import Shiny

struct Recordings: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State var recordings = Data.Recording.Operations.getRecordings()
    
    @State var exportView = false
        
    var body: some View {
        GeometryReader { viewInfo in
            VStack {
                HStack {
                    Spacer()
                    Visuals.Views.CloseButton(whenPressed: { dismiss() })
                }
                VStack {
                    Text("Recorded Loops").font(.largeTitle).fontWeight(.black).frame(maxWidth: .infinity, alignment: .leading).padding([.leading, .trailing])
                    ScrollView {
                        ZStack {
                            if (recordings.count != 0) { RoundedRectangle(cornerRadius: 12.0, style: .continuous).shiny(.iridescent) }
                            VStack {
                                ForEach(Array(recordings), id: \.self) { recording in
                                    if (recording == recordings[0]) { Spacer() }
                                    HStack {
                                        Text("\(recording.name2Show)").foregroundColor(.white).fontWeight(.heavy).blendMode(.difference)
                                        Spacer()
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12.0, style: .continuous).shiny(.hyperGlossy(.gray)).frame(maxWidth: 96)
                                            HStack {
                                                Button(action: { Files.export(recording.path) }, label: {
                                                    Image(systemName: "square.and.arrow.up")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .blendMode(.difference)
                                                }).frame(width: 24, height: 24).padding(8)
                                                Button(action: { Data.Recording.Operations.deleteRecording(recording); recordings = Data.Recording.Operations.getRecordings() }, label: {
                                                    Image(systemName: "trash")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundColor(.red)
                                                        .blendMode(.difference)
                                                }).frame(width: 24, height: 24).padding(8)
                                            }
                                        }
                                    }.padding()
                                    if !(recording == recordings[recordings.count-1]) { Divider() } else { Spacer() }
                                }
                            }
                        }
                    }.padding([.trailing, .leading])
                }
            }
        }
    }
}
