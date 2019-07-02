//
//  FontPointFamilyMetrics.swift
//  MCx...
//
//  Created by marc on 2019.06.30.
//

import Foundation

/// Provides font character metrice for a given font and font size.
///
/// * Uses JSON encoding since an official BinaryEncode/BinaryDecoder does not exist at this time.
/// * Expects fontmetric files to be located in `/opt/local/fontmetrics`.
///
public struct FontPointFamilyMetrics: Codable {
    
    // FONT FAMILY ATTRIBUTES
    
    public let fontFamily: FontHelper.PostscriptName
    //let boundingBox: [String:CGRect]
    public let fontSize: CGFloat
    //
    
    public let ptsAscent: CGFloat
    public let ptsDescent: CGFloat 
    public let ptsLeading: CGFloat
    public let ptsCapHeight: CGFloat
    
    public let glyphUnitsPerEm: CGFloat
    public let ptsPerGlyphUnits: CGFloat
    
    public let unavailableAdvance: CGFloat
    public let unavailableAscent: CGFloat
    public let unavailableDescent: CGFloat
    public let unavailableBounds: CGRect
    public let unavailableOptical: CGRect
    
    // CHARACTER ATTRIBUTES
    
    /// * string.unicodeScalars, utf32: Unicode.Scalar, utf32.value, UTF32Char, UInt32. 
    /// * UTF-8 and UTF-16 are variable length. So, fixed length UTF-32 is used.
    public let lookup: [UTF32Char: FontPointMetrics]
    
    init(
        fontFamily: FontHelper.PostscriptName, 
        fontSize: CGFloat,
        ptsAscent: CGFloat,
        ptsDescent: CGFloat,
        ptsLeading: CGFloat,
        ptsCapHeight: CGFloat,
        glyphUnitsPerEm: CGFloat,
        ptsPerGlyphUnits: CGFloat,
        lookup: [UTF32Char: FontPointMetrics]
        ) {
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        
        /// Font Family Ascent (points)
        self.ptsAscent = ptsAscent
        /// Font Family Descent (points)
        self.ptsDescent = ptsDescent
        /// Font Family Leading (points)
        self.ptsLeading = ptsLeading
        /// Font Family Capitization Height (points)
        self.ptsCapHeight = ptsCapHeight
        
        self.glyphUnitsPerEm = glyphUnitsPerEm
        self.ptsPerGlyphUnits = ptsPerGlyphUnits
        
        self.lookup = lookup
        
        // Compute values for font family
        self.unavailableAdvance = fontSize
        self.unavailableAscent = ptsAscent
        self.unavailableDescent = ptsDescent
        self.unavailableBounds = CGRect(
            x: 0.0, 
            y: 0.0, 
            width: unavailableAdvance, 
            height: fontSize
        )
        self.unavailableOptical = CGRect(
            x: 0.0, 
            y: 0.0, 
            width: unavailableAdvance, 
            height: fontSize
        )
    }
    
    func summary() -> String {
        var str = fontFamily.rawValue
        str.append(" \(fontSize)\n")
        str.append("ptsAscent=\(ptsAscent), ptsDescent=\(ptsDescent)\n")
        return str
    }
    
    /// - Returns: overall total string width, each character advance
    func getAdvances(string: String) -> (overall: CGFloat, sizes: [CGSize]) {
        var sizesList = [CGSize]()
        var widthOverall: CGFloat = 0.0
        for utf32 in string.unicodeScalars {
            let uint32: UTF32Char = utf32.value
            if let metrics = lookup[uint32] {
                sizesList.append(CGSize(width: metrics.advance, height: 0.0))
                widthOverall = widthOverall + metrics.advance
            }
            else {
                sizesList.append(CGSize(width: unavailableAdvance, height: 0.0))
                widthOverall = widthOverall + unavailableAdvance
                print("Warn: \(hexString(utf32)) not available.")
            }
        }
        return (widthOverall, sizesList)
    }
    
    func getBoundingRects(string: String) -> [CGRect] {
        var boundsList = [CGRect]()
        for utf32 in string.unicodeScalars {
            let uint32: UTF32Char = utf32.value
            if let metrics = lookup[uint32] {
                boundsList.append(metrics.rectBounds)
            }
            else {
                boundsList.append(unavailableBounds)
                print("Warn: \(hexString(utf32)) not available.")
            }
        }
        return boundsList
    }
    
    func getOpticalRects(string: String) -> [CGRect] {
        var opticalList = [CGRect]()
        for utf32 in string.unicodeScalars {
            let uint32: UTF32Char = utf32.value
            if let metrics = lookup[uint32] {
                opticalList.append(metrics.rectOptical)
            }
            else {
                opticalList.append(unavailableOptical)
                print("Warn: \(hexString(utf32)) not available.")
            }
        }
        return opticalList
    }

    func toValues(string: String) {
        var result = ""
        for utf32: UnicodeScalar in string.unicodeScalars { // Unicode.Scalar
            let uint32 = utf32.value
            if let metrics = lookup[uint32] {
                result.append("\(metrics._character) ")
                result.append("\(metrics.toUtf8Hex()) ")
                result.append("\(metrics.toUtf16Hex()) ")
                result.append("\(metrics.toInt()) \n")
            }
        }
        print(result)
    }
    
    func wordwrap(string: String, bounds: CGSize) -> [String] {
        fatalError()
    }
    
    internal func hexString(_ uft32: UnicodeScalar) -> String {
        var result = ""
        let string = String(uft32)
        for codeUnit: UTF16.CodeUnit in string.utf16 { // UInt16
            let hexcode = String(format: "%04x", codeUnit)
            result.append("U+\(hexcode) ")
        }
        return result
    }
    
    // MARK: - Class Methods 
    
    static func fileLoad(fontFamily: FontHelper.PostscriptName, fontSize: CGFloat) -> FontPointFamilyMetrics? {
        let filename = FontPointFamilyMetrics.toFilename(fontFamily: fontFamily, fontSize: fontSize)
        do {
            let url = fontmetricsDirUrl.appendingPathComponent(filename)
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let fontmetric = try decoder.decode(FontPointFamilyMetrics.self, from: data)
            return fontmetric
        } 
        catch {
            print("ERROR: failed to load '\(filename)' \n\(error)")
            return nil
        }
    }
    
    static func fileSave(_ fontmetrics: FontPointFamilyMetrics) {
        let filename = FontPointFamilyMetrics.toFilename(
            fontFamily: fontmetrics.fontFamily, 
            fontSize: fontmetrics.fontSize)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(fontmetrics)
            let url = fontmetricsDirUrl.appendingPathComponent(filename)
            try data.write(to: url)
        } 
        catch {
            print("ERROR: failed to save '\(filename)' \n\(error)")
        }
    }
    
    static private func toFilename(fontFamily: FontHelper.PostscriptName, fontSize: CGFloat) -> String {
        let fontFamilyName = fontFamily.rawValue
        let fontSizeStr = String(format: "%.1f", fontSize)
        // let fontSizeStr = String(format: "%.1f", Float(fontSize))
        // let fontSizeStr = fontSize.description 
        // let fontSizeStr = "\(fontSize)"
        
        return "\(fontFamilyName)_\(fontSizeStr).json"
    }
}

public extension FontPointFamilyMetrics {
    enum Error: Swift.Error {
        case failedToDoSomething
    }
}
