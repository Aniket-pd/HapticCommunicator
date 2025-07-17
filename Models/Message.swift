//
//  Message.swift
//  HapticCommunicator
//
//  Created by Aniket prasad on 11/7/25.
//

import Foundation

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let morse: String
    let isSpeech: Bool // true = speech, false = decoded
}

