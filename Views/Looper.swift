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
import SpriteKit
import SwiftUI

struct Looper: View {
    @Environment(\.dismiss) var dismiss
    
    @State var isPresented: Binding<Bool>
    
    @State var isRecording: Bool = false
    @State var recordingStatusIndicatorProgress: Float = 0
    @State var recordingStatusIndicatorProgressRising: Bool = true
    var recordingStatusIndicatorProgressTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
        
    private let Scene = Playground()
    
    var body: some View {
        GeometryReader { viewInfo in
            ZStack {
                ZStack {
                    RoundedRectangle(cornerRadius: (UIScreen.main.value(forKey: "_displayCornerRadius") as! CGFloat))
                        .trim(from: 0, to: CGFloat(recordingStatusIndicatorProgress))
                        .stroke(Color.red, lineWidth: 6.0)
                        .frame(width: (viewInfo.size.height+(viewInfo.safeAreaInsets.top+viewInfo.safeAreaInsets.bottom)), height: (viewInfo.size.width+(viewInfo.safeAreaInsets.leading+viewInfo.safeAreaInsets.trailing)), alignment: .center)
                        .padding(.all, 2.0)
                        .opacity(0.75)
                        .glow(12)
                        .onReceive(recordingStatusIndicatorProgressTimer) { _ in
                            withAnimation(Animation.linear(duration: 0.5)) {
                                if !isRecording {
                                    if (recordingStatusIndicatorProgress > 0) {
                                        recordingStatusIndicatorProgress = 0
                                    }; return
                                }
                                if (recordingStatusIndicatorProgress >= 1 && recordingStatusIndicatorProgressRising) || (recordingStatusIndicatorProgress < 0 && !recordingStatusIndicatorProgressRising) {
                                    recordingStatusIndicatorProgressRising.toggle()
                                } else {
                                    recordingStatusIndicatorProgress += ((recordingStatusIndicatorProgressRising) ? 0.08:-0.08)
                                }
                            }
                        }
                        .rotationEffect(.degrees(270))
                        .scaleEffect(CGSize(width: ((recordingStatusIndicatorProgressRising) ? 1:-1), height: 1))
                        .animation(Animation.easeInOut(duration: 0), value: recordingStatusIndicatorProgressRising)
                        .allowsHitTesting(false)
                }
                VStack {
                    HStack {
                        Spacer()
                        HStack {
                            Text("\(Image(systemName: "escape"))").fontWeight(.semibold).font(Font.system(size:22)).frame(width: 32, height: 32, alignment: .center).foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2)).background(
                                RoundedRectangle(cornerRadius: 14.0)
                                    .foregroundColor(((!isRecording) ? Color.white:Color(red: 0.8, green: 0.8, blue: 0.8)))
                                    .frame(width: 42, height: 42, alignment: .center)
                            )
                            .onTapGesture { if !isRecording { Scene.engine.stopEngine(); dismiss(); isPresented.wrappedValue = false } }
                            Spacer()
                            Text("\(Image(systemName: ((isRecording) ? "record.circle.fill":"record.circle")))").fontWeight(.heavy).font(Font.system(size:24)).frame(width: 32, height: 32, alignment: .center).foregroundColor(((!isRecording) ? Color.accentColor:Color.red)).background(
                                RoundedRectangle(cornerRadius: 14.0)
                                    .foregroundColor(.white)
                                    .frame(width: 42, height: 42, alignment: .center)
                                    .glow(((isRecording) ? 4:1))
                                    .onTapGesture {
                                        if (!isRecording) {
                                            Scene.engine.endRecordingEvent = {
                                                let icon2Show = UIImage(systemName: "record.circle", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!.withTintColor(UIColor(.red), renderingMode: .alwaysOriginal)
                                                Visuals.Notify(title: "Recording ended!", subtitle: "The loop was saved at the Recorded Loops gallery!", icon: icon2Show).present()
                                            }
                                            Scene.engine.setRecordingPointer($isRecording)
                                            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .rigid)
                                            impactFeedbackgenerator.impactOccurred()
                                            Scene.engine.record()
                                        } else { Scene.engine.killRecording() }
                                    })
                        }
                        .frame(maxWidth: 82)
                        .padding([.top], (12+viewInfo.safeAreaInsets.top))
                        .padding([.trailing])
                    }
                    Spacer()
                }
                SpriteView(scene: Scene)
                    .zIndex(-1)
            }
            .ignoresSafeArea()
            .statusBar(hidden: true)
        }
    }
}
