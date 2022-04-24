// NoteFlier

import Foundation
import SwiftUI
import Snap
import FancyScrollView
import Presentation
import Shiny
import SlideOverCard

struct Main: View {
    @State private var showLooper = false
    @State private var showIntro = true
    @State private var showRecordings: OvercastSnapState = .invisible
    
    var body: some View {
        GeometryReader { viewInfo in
            ZStack {
                Text("NoteFlier")
                    .font(Font.system(size:48, design: .rounded))
                    .fontWeight(.black)
                    .padding([.bottom], (viewInfo.size.height*0.6))
                    .shiny(.hyperGlossy(UIColor(Visuals.Utils.createRandomArrayColors(1).first!)))
                    .glow(32)
                    .background(
                        RoundedRectangle(cornerRadius: 14.0)
                            .frame(width: 280, height: 80.0)
                            .shiny(Gradient(colors: Visuals.Utils.createRandomArrayColors(6, appendColors: [
                                Color(red: (234/255), green: (63/255), blue: (63/255), opacity: 1),
                                Color(red: (255/255), green: 0, blue: (101/255), opacity: 1),
                            ])))
                            .shadow(radius: 4)
                            .padding([.bottom], (viewInfo.size.height*0.6))
                    )
                VStack {
                    Button(action: { showLooper.toggle() }, label: {
                        Text("Looper!")
                            .fontWeight(.heavy)
                            .font(Font.system(size: 26))
                            .shiny(.rainbow)
                            .background(
                                    RoundedRectangle(cornerRadius: 32.0)
                                        .frame(width: 160.0, height: 50.0)
                                        .foregroundColor((UIColor.systemBackground == UIColor.white) ? Color(UIColor.black):Color(UIColor.white))
                                        .shadow(radius: 4)
                            )
                            .padding([.bottom], 20)
                    })
                    .present(isPresented: $showLooper, transition: .crossDissolve, style: .fullScreen) { Looper().transition(.scale) }
                    Button(action: { showRecordings = .large }, label: {
                        Text("Saved Loops")
                            .fontWeight(.bold)
                            .font(Font.system(size: 18))
                            .foregroundColor(.white)
                    })
                }
                IntroEgg(show: $showIntro)
                Recordings(displayState: $showRecordings)
            }
            .background(Visuals.Views.DopeBackground())
        }
    }
}

struct Recordings: View {
    @Binding public var displayState: OvercastSnapState
    
    var body: some View {
        GeometryReader { viewInfo in
            SnapDrawer(state: $displayState, large: .paddingToTop(24), tiny: SnapPoint(floatLiteral: (viewInfo.size.height*0.4)), allowInvisible: true) { state in
                FancyScrollView(title: "Recorded Loops", titleColor: Color.primary, headerHeight: (viewInfo.size.height*0.8), scrollUpHeaderBehavior: .parallax, scrollDownHeaderBehavior: .sticky) {
                    VStack {
                        ForEach(Array(recordings), id: \.self) { recording in
                            VStack {
                                HStack {
                                    Text("\(recording.name2Show)").bold()
                                    Text("\(recording.path)").font(Font.system(size: 12, design: .monospaced))
                                }
                                .onTapGesture() {
                                    let view = UIActivityViewController(activityItems: [recording.path], applicationActivities: nil)
                                    UIApplication.shared.windows.first!.rootViewController?.present(view, animated: true, completion: nil)
                                }
                                Divider()
                            } .padding(12)
                        }
                    }
                    .gesture(
                        DragGesture().onChanged({ gesture in
                                if (gesture.predictedEndLocation.y-gesture.startLocation.y) >= 160 {
                                    self.displayState = .invisibleState
                                }
                            }))
                }
                .padding([.top], 14)
            }
            .background(Color(UIColor(white: 0, alpha: 0)))
        }
        .onAppear() {
            self.displayState = .invisibleState
        }
    }
}
