//
//  ferwApp.swift
//  ferw
//
//  Created by Fabio Festa on 14/11/23.
//

import SwiftUI

@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(NoteData())
        }
    }
}
