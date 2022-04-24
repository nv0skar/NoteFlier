// NoteFlier

import Foundation
import SwiftUI
import Snap
import FancyScrollView
import Presentation
import Shiny
import SlideOverCard

struct Main: View {
    @Environment(\.colorScheme) var colorScheme
    
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
                    .blendMode(.overlay)
                    .background(
                        RoundedRectangle(cornerRadius: 14.0)
                            .frame(width: 280, height: 80.0)
                            .shiny(Gradient(colors: Visuals.Utils.createRandomArrayColors(6, appendColors: [
                                Color(red: (234/255), green: (63/255), blue: (63/255), opacity: 1),
                                Color(red: (255/255), green: 0, blue: (101/255), opacity: 1),
                            ])))
                            .glow(8)
                            .shadow(radius: 4)
                            .padding([.bottom], (viewInfo.size.height*0.6))
                    )
                VStack(alignment: .center) {
                    VStack {
                        Button(action: {
                            if !showLooper { showLooper.toggle() }
                        }, label: {
                            Text("Looper!")
                                .fontWeight(.heavy)
                                .font(Font.system(size: 26))
                                .blendMode(.exclusion)
                                .shiny(Gradient(colors: Visuals.Utils.createRandomArrayColors(6, appendColors: [
                                    Color(red: (234/255), green: (63/255), blue: (63/255), opacity: 1),
                                    Color(red: (255/255), green: 0, blue: (101/255), opacity: 1),
                                ])))
                                .background(
                                        RoundedRectangle(cornerRadius: 32.0)
                                            .frame(width: 180.0, height: 60.0)
                                            .shiny(.matte((colorScheme == .light) ? (UIColor(red: (45/255), green: (50/255), blue: (100/255), alpha: 1)):(UIColor.white)))
                                            .shadow(radius: 4)
                                )
                                .padding([.bottom], 32)
                        })
                        .present(isPresented: $showLooper, transition: .crossDissolve, style: .fullScreen, content: { Looper(inContext: $showLooper) })
                        Button(action: {
                            if !showLooper { showIntro.toggle() }
                        }, label: {
                            Text("🏗 OnionWaves 🏗")
                                .fontWeight(.heavy)
                                .font(Font.system(size: 22, design: .monospaced))
                                .foregroundColor((colorScheme == .light) ? Color(UIColor.black):Color(UIColor.white))
                                .blendMode(.exclusion)
                                .shiny(.hyperGlossy(.cyan))
                                .background(
                                        RoundedRectangle(cornerRadius: 32.0)
                                            .frame(width: 240.0, height: 60.0)
                                            .shiny(.glossy((colorScheme == .light) ? (UIColor.yellow):(UIColor.purple)))
                                            .shadow(radius: 4)
                                )
                                .padding([.bottom], 32)
                        })
                    }
                    Spacer()
                    Button(action: {
                        if !showLooper { showRecordings = .large }
                    }, label: {
                        Text("Saved Loops")
                            .fontWeight(.bold)
                            .font(Font.system(size: 18))
                            .foregroundColor((colorScheme == .light) ? Color(UIColor.black):Color(UIColor.white))
                            .frame(width: (viewInfo.size.width*0.5), height: 120, alignment: .bottom)
                            .padding([.bottom], 12)
                    })
                }
                .padding([.top], (viewInfo.size.height*0.5))
                IntroEgg(show: $showIntro)
                Recordings(displayState: $showRecordings)
            }
            .background(Visuals.Views.DopeBackground())
        }
    }
}

struct Recordings: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding public var displayState: OvercastSnapState
    
    var body: some View {
        GeometryReader { viewInfo in
            SnapDrawer(state: $displayState, large: .paddingToTop(24), tiny: SnapPoint(floatLiteral: (viewInfo.size.height*0.4)), allowInvisible: true) { state in
                FancyScrollView(title: "Recorded Loops", titleColor: ((colorScheme == .light) ? Color.black:Color.white), scrollUpHeaderBehavior: .parallax, scrollDownHeaderBehavior: .sticky) {
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
                            } .padding(24)
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
