// NoteFlier

import Foundation
import SwiftUI
import Drops

class Visuals {
    class Views {
        struct DopeBackground: View {
            let emojis2Draw = 6
            let emojiSize = CGFloat(58)
            
            @State var emojiScale: CGFloat = 0
            @State var hapticFeedback = false
            
            var body: some View {
                GeometryReader { viewInfo in
                    ForEach((0...emojis2Draw), id: \.self) { count in
                        Text(String.randomizeEmoji())
                            .font(Font.system(size: emojiSize))
                            .rotationEffect(Angle(radians: Double(Float.random(in: -1.6...1.6))))
                            .position(
                                x: CGFloat.random(in: emojiSize...viewInfo.size.width-emojiSize),
                                y: CGFloat(count*(Int(viewInfo.size.height)/emojis2Draw))
                            )
                            .glow(8)
                            .scaleEffect(emojiScale)
                            .onAppear() {
                                withAnimation(Animation.easeInOut(duration: 0.2)) {
                                    if emojiScale != 1 { emojiScale = 1 }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    if !hapticFeedback {
                                        hapticFeedback.toggle()
                                        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .rigid)
                                        impactFeedbackgenerator.impactOccurred()
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
    
    /* {
        let icon2Show = UIImage(systemName: "record.circle", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!.withTintColor(UIColor(Visuals.Utils.createRandomArrayColors(1).first!), renderingMode: .alwaysOriginal)
        Visuals.Notify(title: "Recording ended!", subtitle: "The loop was saved as: NewLoop_23-04-2022.m4a", icon: icon2Show).present()
    } */
    
    class Utils {
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

extension String{
    static func randomizeEmoji() -> String {
        let range = [UInt32](0x1F601...0x1F64F)
        let char = range[Int(drand48() * (Double(range.count)))]
        let emoji = UnicodeScalar(char)?.description
        return emoji!
    }
}

extension View {
    func glow(_ blur: Float = 32) -> some View {
        ZStack {
            if blur != 0 {
                ForEach(0..<2) { i in
                    Rectangle()
                        .fill(AngularGradient(gradient: Gradient(colors: Visuals.Utils.createRandomArrayColors(2)), center: .center))
                        .mask(self.blur(radius: CGFloat(blur)))
                        .overlay(self.blur(radius: CGFloat(blur-(Float(i)*blur))))
                }
            } else {
                EmptyView()
            }
        }
    }
}
