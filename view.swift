// NoteFlier

import Foundation
import SwiftUI
import Snap
import FancyScrollView
import Presentation
import Shiny

struct SceneView: View {
    @State private var showLooper = false
    @State private var showRecordings: OvercastSnapState = .invisible
    
    var body: some View {
        GeometryReader { viewInfo in
            ZStack {
                VStack {
                    Text("NoteFlier")
                        .font(Font.system(size:48, design: .rounded))
                        .fontWeight(.black)
                        .padding([.bottom], (viewInfo.size.height*0.6))
                        .shiny(.hyperGlossy(UIColor(Visuals.Utils.createRandomArrayColors(1).first!)))
                        .glow(32)
                        .background(
                                RoundedRectangle(cornerRadius: 14.0)
                                    .frame(width: 240, height: 70.0)
                                    .shiny(Gradient(colors: Visuals.Utils.createRandomArrayColors(6, appendColors: [
                                        Color(red: (234/255), green: (63/255), blue: (63/255), opacity: 1),
                                        Color(red: (255/255), green: 0, blue: (101/255), opacity: 1),
                                    ])))
                                    .padding([.bottom], (viewInfo.size.height*0.6))
                        )
                    VStack {
                        Button(action: { showLooper.toggle() }, label: { Text("Looper!") })
                            .present(isPresented: $showLooper, transition: .crossDissolve, style: .fullScreen) { Looper().transition(.scale) }
                        Button(action: { showRecordings = .large }, label: { Text("Saved Loops") })
                    }
                }
                Recordings(displayState: $showRecordings)
            }
            .background(Visuals.Views.DopeBackground().background(LinearGradient(colors: [Color(red: (10/255), green: (10/255), blue: (30/255)), Color(red: (5/255), green: (5/255), blue: (15/255))], startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 0, y: 0))))
        }
    }
}

struct Recordings: View {
    @Binding public var displayState: OvercastSnapState
    
    var body: some View {
        GeometryReader { viewInfo in
            SnapDrawer(state: $displayState, large: .paddingToTop(24), tiny: SnapPoint(floatLiteral: (viewInfo.size.height*0.4)), allowInvisible: true) { state in
                FancyScrollView(title: "Recorded Loops", titleColor: Color.primary, headerHeight: (viewInfo.size.height*0.8), scrollUpHeaderBehavior: .parallax, scrollDownHeaderBehavior: .sticky) {
                    VStack {}
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
