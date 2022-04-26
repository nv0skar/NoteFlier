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
import AVFAudio

class Data {
    struct Recording: Hashable {
        let name2Show: String
        let path: URL
    }
    
    class AudioEffects {
        struct Reverb {
            var wetDryMix: Float
        }
        
        struct Delay {
            var delayTime: TimeInterval
            var feedback: Float
            var lowPassCutoff: Float
            var wetDryMix: Float
        }
        
        struct Distorsion {
            var preGain: Float
            var wetDryMix: Float
        }
        
        class EQ {
            struct Bands {
                var bandwidth: Float
                var bypass: Bool
                var filterType: AVAudioUnitEQFilterType
                var frequency: Float
                var gain: Float
            }
            
            struct Main {
                var bands: [AudioEffects.EQ.Bands]
                var globalGain: Float
            }
        }
    }
    
    class Eggs {
        struct Intro: Hashable {
            let icon: String
            let text: String
        }
    }
}
