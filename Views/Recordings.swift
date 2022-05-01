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
    
    var body: some View {
        GeometryReader { viewInfo in
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle().fill(Color(white: ((colorScheme == .dark) ? 0.19 : 0.93)))
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .font(Font.body.weight(.bold))
                                .scaleEffect(0.416)
                                .foregroundColor(Color(white: ((colorScheme == .dark) ? 0.62 : 0.51)))
                        }
                    }.frame(width: 28, height: 28).padding()
                }
                FancyScrollView(title: "Recorded Loops", titleColor: ((colorScheme == .light) ? Color.black:Color.white), scrollUpHeaderBehavior: .parallax, scrollDownHeaderBehavior: .sticky) {
                    VStack {
                        ForEach(Array(recordings), id: \.self) { recording in
                            VStack {
                                HStack {
                                    Text("\(recording.name2Show)").bold().frame(width: (viewInfo.size.width*0.25), height: 56, alignment: .center)
                                    Text("\(recording.path)").font(Font.system(size: 12, design: .monospaced)).frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .onTapGesture() {
                                    let sheetWindow = (UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene)?.windows.filter(\.isKeyWindow).first
                                    let sheetController = sheetWindow?.rootViewController?.presentedViewController ?? sheetWindow?.rootViewController
                                    sheetController?.present(UIActivityViewController(activityItems: [recording.path], applicationActivities: nil), animated: true)
                                    }
                                }
                                if !(recording == recordings[recordings.count-1]) { Divider() }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                        } .padding([.trailing, .trailing], 62)
                    }
                }
            }
        }
}
