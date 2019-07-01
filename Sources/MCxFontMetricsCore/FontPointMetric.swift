//
//  FontPointMetric.swift
//  MCxFontMetricsCore
//
//  Created by marc on 2019.06.30.
//

import Foundation

public struct FontPointMetric: Codable {
    
    var _character: String // `Character` is not inherently codable
    var _utf16int: UInt16
    var advance: CGFloat
    var ascent: CGFloat
    var descent: CGFloat
    var rectBounding: CGRect
    var rectOptical: CGRect
    
    init(
        _ c: String,
        advance: CGFloat,
        ascent: CGFloat,
        descent: CGFloat,
        rectBounding: CGRect,
        rectOptical: CGRect
        ) throws {
        
        // Verify single character
        if c.count != 1 {
            throw FontPointFamilyMetrics.Error.failedToDoSomething
        }
        // Verify character range
        let unicode32: UnicodeScalar = c.unicodeScalars.first!
        let unicode32Int: UInt32 = unicode32.value
        if unicode32Int < 0x0600 {
            let unicode16: UTF16.CodeUnit = c.utf16.first! // aka UInt16
            _utf16int = unicode16
        }
        else {
            throw FontPointFamilyMetrics.Error.failedToDoSomething
        }
        
        self._character = c
        self.advance = advance
        self.ascent = ascent
        self.descent = descent
        self.rectBounding = rectBounding
        self.rectOptical = rectOptical
    }

    func toUtf8Hex() -> String {
        let utf8CCharArray = _character.utf8CString
        var utf8Str = ""
        for i in 0 ..< utf8CCharArray.count-1 { // -1 ignores null terminator
            let cchar: CChar = utf8CCharArray[i] // Int8
            if cchar >= 0 {
                utf8Str.append(String(format: "%2x ", cchar) )
            }
            else {
                // suffix(3) includes trailing space
                utf8Str.append(String(String(format: "%2x ", cchar).suffix(3)) )
            }
        }
        return "UTF8 \(utf8Str)"
    }
    
    func toUtf16Hex() -> String {
        let character: Character = _character.first!
        let hexa = character.unicodeScalars
            .map { String($0.value, radix: 16, uppercase: true) }
            .joined()
        return hexa
    }
    
    func toInt() -> Int {
        return Int(_utf16int)
    }
        
    
}
