// NoteFlier

import Foundation
import SwiftUI
import SlideOverCard

struct IntroEgg: View {
    @Binding var show: Bool
    
    var body: some View {
        SlideOverCard(isPresented: $show) {
            ZStack {
                VStack(alignment: .center, spacing: 25) {
                    VStack {
                        Text("New around here? ").font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                        Text("This app is called NoteFlier a fancy tone generator")
                            .multilineTextAlignment(.center)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 25.0, style: .continuous).shiny(.iridescent)
                            LazyVStack {
                                HStack {
                                    Text("\(Image(systemName: "questionmark.app.dashed"))").fontWeight(.heavy).font(Font.system(size:24))
                                        .frame(maxWidth: 56, alignment: .leading)
                                    Text("The obstacles spawned change the waveform algorithm randomly").font(Font.system(size: 16, design: .rounded))
                                }
                                Divider()
                                HStack {
                                    Text("\(Image(systemName: "record.circle"))").fontWeight(.heavy).font(Font.system(size:24))
                                        .frame(maxWidth: 56, alignment: .leading)
                                    Text("Record your tones (Up to 6 seconds) (when the app restarts the buffer that allocates the path of the recordings are freed up and they're not saved 😓)").font(Font.system(size: 16, design: .rounded))
                                }
                                Divider()
                                HStack {
                                    Text("\(Image(systemName: "cursorarrow.rays"))").fontWeight(.heavy).font(Font.system(size:24))
                                        .frame(maxWidth: 56, alignment: .leading)
                                    Text("Export them (Go to: Saved Loops and click the Path to export your recordings)").font(Font.system(size: 16, design: .rounded))
                                }
                            } .padding(12)
                        }
                    
                    VStack(spacing: 0) {
                        Button("Let's go!", action: {
                            show = false
                        }).buttonStyle(SOCActionButton())
                    }
                }.frame(height: 460)
            }
        }
    }
}
