//
//  Note.swift
//  ferw
//
//  Created by Fabio Festa on 21/11/23.
//

import Foundation

import SwiftUI


struct Note: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var content: String
    var creationDate = Date()

}
