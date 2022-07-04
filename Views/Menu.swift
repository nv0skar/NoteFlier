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
import SwiftUI
import Presentation
import Shiny

struct Menu: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var intro: Bool
    @Binding var looper: Bool
    @Binding var recordings: Bool
    
    var body: some View {
        GeometryReader { viewInfo in
            VStack {
                Text("NoteFlier")
                    .foregroundColor(.white)
                    .fontWeight(.black)
                    .font(Font.system(size:48, design: .rounded))
                    .shadow(color: Color.black, radius: 1, x: -1, y: -1)
                    .blendMode(.overlay)
                    .background(
                        RoundedRectangle(cornerRadius: 14.0)
                            .frame(width: 280, height: 80.0)
                            .shiny(Gradient(colors: Visuals.Extras.createRandomArrayColors(6, appendColors: [
                                Color(red: (234/255), green: (63/255), blue: (63/255), opacity: 1),
                                Color(red: (255/255), green: 0, blue: (101/255), opacity: 1),
                            ])))
                            .glow(8)
                            .shadow(radius: 4)
                    )
                    .padding([.top, .bottom], 64)
                Spacer()
                VStack {
                    VStack {
                        Button(action: { looper.toggle() }, label: {
                            Text("Looper!")
                                .fontWeight(.heavy)
                                .font(Font.system(size: 26))
                                .shadow(color: Color.black, radius: 1, x: -1, y: -1)
                                .blendMode(.exclusion)
                                .shiny(Gradient(colors: Visuals.Extras.createRandomArrayColors(6, appendColors: [
                                    Color(red: (234/255), green: (63/255), blue: (63/255), opacity: 1),
                                    Color(red: (255/255), green: 0, blue: (101/255), opacity: 1),
                                ])))
                                .background(
                                    RoundedRectangle(cornerRadius: 32.0)
                                        .frame(width: 180.0, height: 60.0)
                                        .shiny(.matte((colorScheme == .light) ? (UIColor(red: (45/255), green: (50/255), blue: (100/255), alpha: 1)):(UIColor.white)))
                                        .shadow(radius: 4)
                                )
                        })
                        .padding(.bottom, 52)
                        Button(action: { intro.toggle() }, label: {
                            Text("🏗 OnionWaves 🏗")
                                .fontWeight(.heavy)
                                .font(Font.system(size: 22, design: .rounded))
                                .shadow(color: Color.black, radius: 1, x: -1, y: -1)
                                .foregroundColor((colorScheme == .light) ? Color(UIColor.black):Color(UIColor.white))
                                .blendMode(.exclusion)
                                .shiny(Gradient(colors: Visuals.Extras.createRandomArrayColors(6, appendColors: [
                                    Color(red: (234/255), green: (63/255), blue: (63/255), opacity: 1),
                                    Color(red: (255/255), green: 0, blue: (101/255), opacity: 1),
                                ])))
                                .background(
                                    RoundedRectangle(cornerRadius: 32.0)
                                        .frame(width: 240.0, height: 60.0)
                                        .shiny(.glossy((colorScheme == .light) ? (UIColor.yellow):(UIColor.purple)))
                                        .shadow(radius: 4)
                                )
                        })
                    }
                    Spacer()
                    Button(action: { recordings.toggle() }, label: {
                        Text("Saved Loops")
                            .fontWeight(.bold)
                            .font(Font.system(size: 18))
                            .foregroundColor((colorScheme == .light) ? Color(UIColor.black):Color(UIColor.white))
                    })
                    .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: (viewInfo.size.height*0.35))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding()
        }
    }
}
