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
import SQLite

class Data {
    class Recording {
        static let dbTable = Table("recordings")
        
        static var name2Show = Expression<String>("name2Show")
        static var path = Expression<String>("path")
        
        struct Constructor: Hashable {
            let name2Show: String
            let path: URL
        }
        
        class Operations {
            static func getRecordings() -> [Constructor] {
                var recordings: [Constructor] = []
                for recording in try! Commons.db.connection.prepare(dbTable) {
                    recordings.append(Constructor(name2Show: recording[name2Show], path: URL(string: "\(recording[path])")!))
                }; return recordings
            }
            
            static func saveRecording(_ recording: Constructor) {
                let toInsert = dbTable.insert(name2Show <- recording.name2Show, path <- recording.path.absoluteString)
                let _ = try! Commons.db.connection.run(toInsert); Utils.log("New recording (\(recording.name2Show)) saved!")
            }
        }
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
