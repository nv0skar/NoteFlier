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
import Drops

class Visuals {
    class Views {
        struct CloseButton: View {
            @Environment(\.colorScheme) var colorScheme
            
            var whenPressed: (() -> ())
            
            var body: some View {
                Button(action: { whenPressed() }) {
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
        }
        
        struct DopeBackground: View {            
            let emojis2Draw = 6
            let emojiSize: CGFloat = 58
                        
            @State var emojiScale: CGFloat = 0
            @State var hapticFeedback = false
            
            var body: some View {
                GeometryReader { viewInfo in
                    ForEach((0...emojis2Draw), id: \.self) { count in
                        Text(["🎧", "🔈", "🎹", "🎛️", "🎙️", "🎸", "🎺", "🎷"].randomElement()!)
                            .font(Font.system(size: CGFloat.random(in: (emojiSize-6)...(emojiSize+6))))
                            .rotationEffect(Angle(radians: Double(Float.random(in: -1.6...1.6))))
                            .position(
                                x: CGFloat.random(in: CGFloat(emojiSize)...(viewInfo.size.width-CGFloat(emojiSize))),
                                y: CGFloat(count*(Int(viewInfo.size.height)/emojis2Draw))
                            )
                            .glow(12)
                            .scaleEffect(emojiScale)
                            .onAppear() {
                                withAnimation(Animation.spring(dampingFraction: 0.6)) {
                                    emojiScale = CGFloat.random(in: 1.0...1.1)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    if !hapticFeedback {
                                        hapticFeedback.toggle()
                                        Utils.hapticImpulse(.medium)
                                    }
                                }
                            }
                            .ignoresSafeArea()
                    }
                }
            }
        }
    }
    
    class Notify {
        private var theDrop: Drop
        
        init(title: String, subtitle: String? = nil, subtitleNumberOfLines: Int = 1, icon: UIImage? = nil, action: Drop.Action? = nil, position: Drop.Position = Drop.Position.top, duration: Drop.Duration = Drop.Duration.recommended, accessibility: Drop.Accessibility? = nil) {
            theDrop = Drop(title: title, titleNumberOfLines: 1, subtitle: subtitle, subtitleNumberOfLines: subtitleNumberOfLines, icon: icon, action: action, position: position, duration: duration, accessibility: accessibility)
        }
        
        public func present() {
            Drops.show(theDrop)
        }
    }
    
    class Extras {
        static func createRandomArrayColors(_ count: Int, appendColors: [Color]? = nil) -> [Color] {
            var colors: [Color] = []
            if let toAppend = appendColors { colors.append(contentsOf: toAppend) }
            for _ in 0...count {
                colors.append(Color(red: ((CGFloat.random(in: 0...255))/255.0), green: ((CGFloat.random(in: 0...255))/255.0), blue: ((CGFloat.random(in: 0...255))/255.0)))
            }
            return colors
        }
    }
}

extension View {
    func glow(_ blur: Float = 32) -> some View {
        ZStack {
            if blur != 0 {
                ForEach(0..<2) { i in
                    Rectangle()
                        .fill(AngularGradient(gradient: Gradient(colors: Visuals.Extras.createRandomArrayColors(2)), center: .center))
                        .mask(self.blur(radius: CGFloat(blur)))
                        .overlay(self.blur(radius: CGFloat(blur-(Float(i)*blur))))
                }
            } else {
                EmptyView()
            }
        }
    }
}
