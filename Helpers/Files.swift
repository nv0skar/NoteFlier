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
import UIKit

class Files {
    static func export(_ file: URL) {
        let sheetWindow = (UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene)?.windows.filter(\.isKeyWindow).first
        let sheetController = sheetWindow?.rootViewController?.presentedViewController ?? sheetWindow?.rootViewController
        sheetController?.present(UIActivityViewController(activityItems: [file], applicationActivities: nil), animated: true)
        Utils.log("Recording (\(file.absoluteString)) exported!")
    }
    
    static func deleteFile(_ file: URL) {
        do {
            try FileManager.default.removeItem(at: file)
            Utils.log("\(file.absoluteString) deleted!")
        } catch {}
    }
}
