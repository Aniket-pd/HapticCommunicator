//
//  MorseCodeConverter.swift
//  HapticCommunicator
//
//  Created by Aniket prasad on 11/7/25.
//



import Foundation

struct MorseCodeConverter {
    private let morseMap: [Character: String] = [
        "A": "·−",    "B": "−···",  "C": "−·−·",  "D": "−··",
        "E": "·",     "F": "··−·",  "G": "−−·",   "H": "····",
        "I": "··",    "J": "·−−−",  "K": "−·−",   "L": "·−··",
        "M": "−−",    "N": "−·",    "O": "−−−",   "P": "·−−·",
        "Q": "−−·−",  "R": "·−·",   "S": "···",   "T": "−",
        "U": "··−",   "V": "···−",  "W": "·−−",   "X": "−··−",
        "Y": "−·−−",  "Z": "−−··",
        "1": "·−−−−", "2": "··−−−", "3": "···−−", "4": "····−",
        "5": "·····", "6": "−····", "7": "−−···", "8": "−−−··",
        "9": "−−−−·", "0": "−−−−−",
        " ": " "
    ]

    func textToMorse(_ text: String) -> String {
        let uppercased = text.uppercased()
        var morseResult = ""
        for char in uppercased {
            if let morseChar = morseMap[char] {
                morseResult += morseChar + " "
            } else {
                // Skip characters not in Morse map
                continue
            }
        }
        return morseResult.trimmingCharacters(in: .whitespaces)
    }

    func morseToText(_ morse: String) -> String {
        let reversedMap = Dictionary(uniqueKeysWithValues: morseMap.map { ($0.value, $0.key) })
        let words = morse.components(separatedBy: "   ") // 3 spaces = word gap
        var textResult = ""

        for word in words {
            let letters = word.components(separatedBy: " ")
            for letter in letters {
                if let textChar = reversedMap[letter] {
                    textResult.append(textChar)
                }
            }
            textResult.append(" ")
        }
        return textResult.trimmingCharacters(in: .whitespaces)
    }
}
