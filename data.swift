// NoteFlier

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
