// NoteFlier

import Foundation
import SpriteKit
import SwiftUI

struct Looper: View {
    @Environment(\.dismiss) var dismiss
    @State var isRecording: Bool = false
    @State var recorded: Bool = false
    @State var recordingProgress: Int = 0
    
    private let Scene = Playground()
    
    var body: some View {
        GeometryReader { viewInfo in
            ZStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 54)
                        .trim(from: 0, to: CGFloat(Int(recordingProgress)))
                        .stroke(Color.red, lineWidth: 6.0)
                        .padding(.all, 2.0)
                        .opacity(0.75)
                        .glow(12)
                        .allowsHitTesting(false)
                        .ignoresSafeArea()
                }
                Text("\(Image(systemName: ((isRecording) ? "record.circle.fill":"record.circle")))").fontWeight(.heavy).font(Font.system(size:24)).frame(width: 32, height: 32, alignment: .center).foregroundColor(.red).background(
                    RoundedRectangle(cornerRadius: 14.0)
                        .foregroundColor(((!recorded) ? Color.white:Color(red: 0.8, green: 0.8, blue: 0.8)))
                        .frame(width: 42, height: 42, alignment: .center)
                        .glow(((isRecording) ? 8:(!recorded) ? 2:1))
                )
                .position(x: (viewInfo.size.width-45), y: 24)
                .onTapGesture {
                    if isRecording || recorded { return }
                    Scene.engine.endRecordingEvent = {
                        let icon2Show = UIImage(systemName: "record.circle", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!.withTintColor(UIColor(.green), renderingMode: .alwaysOriginal)
                        Visuals.Notify(title: "Recording ended!", subtitle: "The loop was saved at the Recorded Loops gallery!", icon: icon2Show).present()
                    }
                    Scene.engine.setRecordingPointer($isRecording)
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .rigid)
                    impactFeedbackgenerator.impactOccurred()
                    Scene.engine.record()
                    withAnimation(Animation.linear(duration: Double(Audio.recordDuration)*100), {
                        recordingProgress = 100
                    })
                    recorded = true
                }
                Text("\(Image(systemName: "escape"))").fontWeight(.semibold).font(Font.system(size:22)).frame(width: 32, height: 32, alignment: .center).foregroundColor(.black).background(
                    RoundedRectangle(cornerRadius: 14.0)
                        .foregroundColor(((!isRecording) ? Color.white:Color(red: 0.8, green: 0.8, blue: 0.8)))
                        .frame(width: 42, height: 42, alignment: .center)
                )
                .position(x: (viewInfo.size.width-102), y: 24)
                .onTapGesture {
                    if !isRecording { dismiss() }
                }
                SpriteView(scene: Scene)
                    .zIndex(-1)
                    .ignoresSafeArea()
            }
            .statusBar(hidden: true)
        }
    }
}
