//
//  FontMetricsExtractor.swift
//  MCxFontMetricsCore
//
//  Created by marc on 2019.06.30.
//

import Foundation

/// Provides metrics for a specific font.
///
/// `font_size = N_points / em`
///
/// `(N_points / em) / (glyph_units / em) = N_points / glyph_units`
///
struct FontMetricsExtractor {
    
    ///
    let cgFontFamily: FontHelper.PostscriptName
    ///
    let cgFont: CGFont
    /// Font size in points.
    let cgFontSize: CGFloat
    private let ctFont: CTFont
    
    init(fontFamily: FontHelper.PostscriptName, fontSize: CGFloat) throws {
        self.cgFontFamily = fontFamily
        self.cgFontSize = fontSize
        let cfsFontName: CFString = fontFamily.rawValue as CFString
        
        // Use either the font's PostScript name or full name
        if let font = CGFont(cfsFontName) {
            self.cgFont = font
            self.ctFont = CTFontCreateWithGraphicsFont(
                font,     // graphicsFont: CGFont
                fontSize, // size: CGFloat. 0.0 defaults to 12.0
                nil,      // matrix: UnsafePointer<CGAffineTransforms>?
                nil       // attributes: CTFontDescriptor?
            )
        }
        else {
            throw MCxFontMetrics.Error.fontNotFound
        }
    }
    
    /// - Returns: font space values
    func getAdvances(string: String) -> (overall: CGFloat, sizes: [CGSize])? {
        //let string = filterToExisting(string)
        var unichars = [UniChar](string.utf16)
        var glyphs = [CGGlyph](repeating: 0, count: unichars.count)
        
        
        guard CTFontGetGlyphsForCharacters(
            ctFont, // font: CTFont
            &unichars, // characters: UnsafePointer<UniChar>
            &glyphs, // UnsafeMutablePointer<CGGlyph>
            unichars.count // count: CFIndex
            )
            else {
                return nil
        }
        let glyphsCount = glyphs.count
        
        var advances = [CGSize](repeating: CGSize(width: 0.0, height: 0.0), count: glyphsCount)
        let widthOverall: Double = CTFontGetAdvancesForGlyphs(
            ctFont,      // font: CTFont
            .horizontal, // orientation: CFFontOrientation
            glyphs,      // glyphs: UnsafePointer<CGGlyph>
            &advances,   // advances: UnsafeMutablePointer<CGSize>?
            glyphsCount  // count: CFIndex
        )
        
        return (overall: CGFloat(widthOverall), sizes: advances)
    }
    
    func getBoundingRects(string: String) -> (overall: CGRect, list: [CGRect])? {
        var unichars = [UniChar](string.utf16)
        var glyphs = [CGGlyph](repeating: 0, count: unichars.count)
        
        guard CTFontGetGlyphsForCharacters(
            ctFont, // font: CTFont
            &unichars, // characters: UnsafePointer<UniChar>
            &glyphs, // UnsafeMutablePointer<CGGlyph>
            unichars.count // count: CFIndex
            )
            else {
                return nil
        }
        let glyphsCount = glyphs.count
        
        var boundingRects = [CGRect](repeating: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0), count: glyphsCount)
        // Result: font design metrics transformed into font space.
        let boundingBox = CTFontGetBoundingRectsForGlyphs(
            ctFont,         // font: CTFont
            .horizontal,    // orientation: CTFontOrientation default|horizontal|vertical
            glyphs,         // glyphs: UnsafePointer<CGGlyph>
            &boundingRects, // boundingRects: UnsafeMutablePointer<CGRect>?
            glyphsCount     // count: CFIndex
        )
        return (overall: boundingBox, list: boundingRects)
    }
    
    func getGlyphs(string: String) -> [CGGlyph]? {
        var unichars = [UniChar](string.utf16)
        var glyphs = [CGGlyph](repeating: 0, count: unichars.count)
        
        guard CTFontGetGlyphsForCharacters(
            ctFont, // font: CTFont
            &unichars, // characters: UnsafePointer<UniChar>
            &glyphs, // UnsafeMutablePointer<CGGlyph>
            unichars.count // count: CFIndex
            )
            else {
                return nil
        }
        
        return glyphs
    }
    
    func createGlyphToUnicodeMap() ->  [CGGlyph : UnicodeScalar] {
        
        // Get all characters of the font with CTFontCopyCharacterSet().
        let charset = CTFontCopyCharacterSet(ctFont) as CharacterSet
        
        var glyphToUnicode = [CGGlyph : UnicodeScalar]() // Start with empty map.
        
        // Enumerate all Unicode scalar values from the character set:
        for plane: UInt8 in 0...16 where charset.hasMember(inPlane: plane) {
            for unicode in UTF32Char(plane) << 16 ..< UTF32Char(plane + 1) << 16 {
                if let unicodeScalar = UnicodeScalar(unicode), charset.contains(unicodeScalar) {
                    
                    // Get glyph for this `uniChar` ...
                    // let unichar16 = [UniChar](unicodeScalar.utf16)
                    let unichar16: [UTF16.CodeUnit] = Array(unicodeScalar.utf16)
                    var glyphs = [CGGlyph](repeating: 0, count: unichar16.count)
                    
                    if CTFontGetGlyphsForCharacters(
                        ctFont,         // font: CTFont
                        unichar16,      // characters: UnsafePointer<UniChar>
                        &glyphs,        // UnsafeMutablePointer<CGGlyph>
                        unichar16.count // count: CFIndex
                        ) {
                        // ... and add it to the map.
                        glyphToUnicode[glyphs[0]] = unicodeScalar
                    }
                }
            }
        }
        
        return glyphToUnicode
    }
    
    func createUTF32MetricsMap() ->  [UTF32Char: FontPointMetrics] {
        // Get all characters of the font with CTFontCopyCharacterSet().
        let charset = CTFontCopyCharacterSet(ctFont) as CharacterSet
        
        var utf32ToMetrics = [UTF32Char: FontPointMetrics]() // Start with empty map.
        
        // Enumerate all Unicode scalar values from the character set:
        for plane: UInt8 in 0...16 where charset.hasMember(inPlane: plane) {
            // 
            for utf32Char: UTF32Char in UTF32Char(plane) << 16 ..< UTF32Char(plane + 1) << 16 {
                
                if utf32Char >= UInt32.max {
                    print("WARNING: utf32Char >= UInt32.max \(utf32Char)")
                    continue
                }
                
                guard let unicodeScalar = UnicodeScalar(utf32Char)
                    else {
                        continue
                }
                
                if charset.contains(unicodeScalar) == false {
                    continue
                }

                var characterStr = ""
                characterStr.append(Character(unicodeScalar))
                
                let utf16Char = UTF16Char(truncatingIfNeeded: utf32Char)
                let utf16CharArray: [UTF16.CodeUnit] = [utf16Char]
                
                var glyphs = [CGGlyph](repeating: 0, count: utf16CharArray.count)
                if CTFontGetGlyphsForCharacters(
                    ctFont,              // font: CTFont
                    utf16CharArray,      // characters: UnsafePointer<UniChar>
                    &glyphs,             // UnsafeMutablePointer<CGGlyph>
                    utf16CharArray.count // count: CFIndex
                    ) {
                    // ... and add it to the map.
                    
                    let advance = getAdvances(string: characterStr)!.overall
                    let rectBounds = getBoundingRects(string: characterStr)!.list[0]
                    let rectOptical = getOpticalRects(string: characterStr)!.list[0]
                    
                    do {
                        let metrics = try FontPointMetrics(
                            characterStr,
                            advance: advance,
                            rectBounds: rectBounds,
                            rectOptical: rectOptical 
                        )
                        
                        utf32ToMetrics[utf32Char] = metrics
                    }
                    catch {
                        print("WARNING: \(characterStr) not found in CharacterSet")
                    }
                    
                    
                }
            }
        }
        
        return utf32ToMetrics
    }
    
    // :WIP: getGlyphWithMaxAscent has not been fully implemented
    func getGlyphWithMaxAscent() -> CGGlyph {
        var maxAscent: CGFloat = 0.0
        var resultGlyph: CGGlyph = 0
        var _ = CGGlyph(0) // resultGlyph
        for i in 0 ..< cgFont.numberOfGlyphs {
            let glyph = CGGlyph(i)
            
            let boundingBox = CTFontGetBoundingRectsForGlyphs(
                ctFont,      // font: CTFont
                .horizontal, // orientation: CTFontOrientation
                [glyph],     // glyphs: UnsafePointer<CGGlyph>
                nil,         // boundingRects: UnsafeMutablePointer<CGRect>?
                1            // count: CFIndex
            )
            
            let glyphTotalHeight = boundingBox.height
            let glyphDescent = -boundingBox.origin.y
            
            if glyphTotalHeight - glyphDescent > maxAscent {
                resultGlyph = glyph
                maxAscent = glyphTotalHeight - glyphDescent
            }
            
            let _: Character = "A"
            
            //cgFont.table(for: <#T##UInt32#>)
            
            //if let glyphNameCFStr = cgFont.name(for: cgGlyph) {
            //    print("\(glyphNameCFStr)")
            //    var glyphs = [CGGlyph](repeating: 0, count: 1)
            //    var bboxes = [CGRect](repeating: CGRect(x: 0, y: 0, width: 0, height: 0), count: 1)
            //    if cgFont.getGlyphBBoxes(
            //        glyphs: &glyphs, // UnsafePointer<CGGlyph>
            //        count: 1, // Int
            //        bboxes: &bboxes // UnsafeMutablePointer<CGRect>
            //        ) {
            //        //if bboxes[0].height >  {
            //        //    
            //        //}
            //    }
            //    cgFont.getGlyphWithGlyphName(name: glyphNameCFStr)
            //}
            
        }
        
        return resultGlyph
    }
    
    func getGlyphWithMaxDecent() {
        
    }
    
    
    func getOpticalRects(string: String) -> (overall: CGRect, list: [CGRect])? {
        var unichars = [UniChar](string.utf16)
        var glyphs = [CGGlyph](repeating: 0, count: unichars.count)
        
        guard CTFontGetGlyphsForCharacters(
            ctFont, // font: CTFont
            &unichars, // characters: UnsafePointer<UniChar>
            &glyphs, // UnsafeMutablePointer<CGGlyph>
            unichars.count // count: CFIndex
            )
            else {
                return nil
        }
        let glyphsCount = glyphs.count
        
        let options: CFOptionFlags = 0 // Reserved, set to zero.
        var opticalRects = [CGRect](repeating: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0), count: glyphsCount)
        let opticalBox = CTFontGetOpticalBoundsForGlyphs(
            ctFont,        // font: CTFont
            glyphs,        // glyphs: UnsafePointer<CGGlyph>
            &opticalRects, // boundingRects: UnsafeMutablePointer<CGRect>?
            glyphsCount,   // count: CFIndex
            options        // options: CFOptionFlags aka UInt
        )
        
        return (overall: opticalBox, list: opticalRects)
    }
    
    /// ptsAscent: max distance above baseline in points
    func ptsAscent() -> CGFloat {
        let ascentGlyphUnits = CGFloat(cgFont.ascent)
        return ascentGlyphUnits * ptsPerGlyphUnits()
    }
    
    /// ptsDescent: max distance below baseline in points
    func ptsDescent() -> CGFloat {
        let descentGlyphUnits = CGFloat(cgFont.descent)
        return descentGlyphUnits * ptsPerGlyphUnits()
    }
    
    /// ptsLeading: spacing between consecutive text lines in points
    func ptsLeading() -> CGFloat {
        let leadingGlyphUnits = CGFloat(cgFont.leading)
        return leadingGlyphUnits * ptsPerGlyphUnits()
    }
    
    /// ptsCapHeight: distance baseline to flat capital letters top
    func ptsCapHeight() -> CGFloat {
        let capHeightGlyphUnits = CGFloat(cgFont.capHeight)
        return capHeightGlyphUnits * ptsPerGlyphUnits()
    }
    
    /// xHeight: distance baseline to top of flat, non-ascending lowercase letters (e.g. "x")
    func xHeight() -> CGFloat {
        let xHeightGlyphUnits = CGFloat(cgFont.xHeight)
        return xHeightGlyphUnits * ptsPerGlyphUnits()
    }
    
    /// italicAngle: degrees counter-clockwise from the vertical
    func italicAngle() -> CGFloat {
        return cgFont.italicAngle
    }
    
    /// - Returns: glyph units/em
    func glyphUnitsPerEm() -> CGFloat {
        return CGFloat(cgFont.unitsPerEm)
    }
    
    /// - Returns: font points per glyph units
    func ptsPerGlyphUnits() -> CGFloat {
        return cgFontSize / glyphUnitsPerEm()
    }
    
    func showCharacters(string: String) {
        let cfStr = string as CFString
        let range = CFRange(location: 0, length: string.utf16.count)
        var buffer = [UniChar](repeating: 0, count: string.utf16.count)
        CFStringGetCharacters(
            cfStr,  // theString: CFString!
            range,  // range: CFRange
            &buffer // buffer: UnsafeMutablePointer<UniChar>!
        )
        
        var i = 0
        for idx in string.indices {
            let unichar: UniChar = buffer[i] // aka UTF16Char, UInt16
            let hexcode = String(format: "%04x", unichar)
            let character: Character = string[idx]
            
            let s = String(character)
            let utf8CCharArray = s.utf8CString
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
            
            print("Unicode U+\(hexcode) UTF8 \(utf8Str) '\(character)'")
            
            i = i + 1
        }
    }
    
    func showFontInfo() {
        // public typealias CGGlyph = CGFontIndex = UInt16
        
        let cfStringDefault = "nil" as CFString
        for i in 0 ..< 10 {
            let glyphName = cgFont.name(for: CGGlyph(i))
            print("[\(i)] \(glyphName ?? cfStringDefault)")
        }
        
        
        // Glyph count: 3,377 (expected & actual)
        print("cgFont.numberOfGlyphs=\(cgFont.numberOfGlyphs)")
        
        print("canCreatePostScriptSubset aka `CGFontPostScriptFormat.type*`")
        print("   type1: \(cgFont.canCreatePostScriptSubset(CGFontPostScriptFormat.type1))")
        print("   type3: \(cgFont.canCreatePostScriptSubset(CGFontPostScriptFormat.type3))")
        print("  type42: \(cgFont.canCreatePostScriptSubset(CGFontPostScriptFormat.type42))")
    }
    
    // MARK: - Glyph Space
    
    /// Provides glyph names. `from` and `to` are range checked.
    ///
    /// - Returns: names in range CGGlyph(from) ..< CGGlyph(to) or `nil` if range check fails.
    func gyphNames(fromIdx: Int, toIdx: Int) -> [String]? {
        guard fromIdx >= 0, 
            toIdx <= cgFont.numberOfGlyphs,
            fromIdx < toIdx
            else {
                return nil
        }
        var result = [String]()
        
        for i in fromIdx ..< toIdx {
            let cgGlyph = CGGlyph(i)
            if let glyphNameCFStr = cgFont.name(for: cgGlyph) {
                result.append("\(glyphNameCFStr)")
            }
        }
        return result
    }
    
}
