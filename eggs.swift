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
import SlideOverCard

struct IntroEgg: View {
    @Binding var show: Bool
    
    var body: some View {
        SlideOverCard(isPresented: $show, options: [.hideExitButton]) {
            ZStack {
                VStack(alignment: .center, spacing: 25) {
                    VStack {
                        Text(Fixed.Eggs.Intro.title).font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                        Text(Fixed.Eggs.Intro.subtitle)
                            .multilineTextAlignment(.center)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 25.0, style: .continuous).shiny(Gradient(colors: [Color(UIColor(red: (70/255), green: (60/255), blue: (110/255), alpha: 1)), Color(UIColor(red: (50/255), green: (50/255), blue: (90/255), alpha: 1))]))
                            ScrollView {
                                ForEach(Fixed.Eggs.Intro.features, id: \.self) { intro in
                                    HStack {
                                        Text("\(Image(systemName: intro.icon))").fontWeight(.heavy).font(Font.system(size:24))
                                            .frame(width: 56, height: 56, alignment: .center).foregroundColor(.white)
                                        Text(intro.text).fontWeight(.bold).font(Font.system(size: 16, design: .rounded)).foregroundColor(.white).frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    if !(intro == Fixed.Eggs.Intro.features[Fixed.Eggs.Intro.features.count-1]) { Divider() }
                                }
                            } .padding(24)
                        }
                    
                    VStack(spacing: 0) {
                        Button("Let's go!", action: { show.toggle() }).buttonStyle(SOCActionButton())
                    }
                    .padding([.bottom], 12)
                } .frame(maxHeight: 660)
            }
        }
    }
}
