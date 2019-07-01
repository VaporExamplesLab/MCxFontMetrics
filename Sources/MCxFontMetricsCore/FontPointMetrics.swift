//
//  FontPointMetrics.swift
//  MCxFontMetricsCore
//
//  Created by marc on 2019.06.30.
//

import Foundation

public struct FontPointMetrics: Codable {
    
    let _character: String // `Character` is not inherently codable
    let _utf16: String
    let advance: CGFloat
    let rectBounds: CGRect
    let rectOptical: CGRect
    
    init(
        _ characterStr: String,
        advance: CGFloat,
        rectBounds: CGRect,
        rectOptical: CGRect
        ) throws {
        
        // Verify single character
        if characterStr.count != 1 {
            throw FontPointFamilyMetrics.Error.failedToDoSomething
        }

        var utf16HexStr = ""
        var notFirst = false
        for utf16Char: UTF16Char in characterStr.utf16 { // UInt16
            if notFirst {
                utf16HexStr.append(" ")
            }
            let hexcode = String(format: "%04x", utf16Char)
            utf16HexStr.append("U+\(hexcode)")
            notFirst = true
        }
        self._utf16 = utf16HexStr
        
        self._character = characterStr
        self.advance = advance
        self.rectBounds = rectBounds
        self.rectOptical = rectOptical
    }

    func toUtf8Hex() -> String {
        var utf8HexStr = "UTF-8"
        for utf8Char: UTF8Char in _character.utf8 { // UInt8
            let hexcode = String(format: "%04x", utf8Char)
            utf8HexStr.append(" \(hexcode)")
        }
        return utf8HexStr
    }
    
    func toUtf16Hex() -> String {
        var utf16HexStr = ""
        var notFirst = false
        for utf16Char: UTF16Char in _character.utf16 { // UInt16
            if notFirst {
                utf16HexStr.append(" ")
            }
            let hexcode = String(format: "%04x", utf16Char)
            utf16HexStr.append("U+\(hexcode)")
            notFirst = true
        }
        return utf16HexStr
    }
    
    /// :WIP: unverified
    func toInt() -> Int {
        if let unicodeScalar = _character.unicodeScalars.first {
            let uint32 = unicodeScalar.value
            return Int(uint32)
        }
        return 0
    }
    
}
