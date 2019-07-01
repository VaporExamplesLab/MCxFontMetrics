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
    
    // CHARACTER ATTRIBUTES
    
    public let lookup: [UInt32: FontPointMetric] = [UInt32: FontPointMetric]()
    
    init(
        fontFamily: FontHelper.PostscriptName, 
        fontSize: CGFloat,
        ptsAscent: CGFloat,
        ptsDescent: CGFloat,
        ptsLeading: CGFloat,
        ptsCapHeight: CGFloat,
        glyphUnitsPerEm: CGFloat,
        ptsPerGlyphUnits: CGFloat
        ) {
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        
        self.ptsAscent = ptsAscent
        self.ptsDescent = ptsDescent
        self.ptsLeading = ptsLeading
        self.ptsCapHeight = ptsCapHeight
        
        self.glyphUnitsPerEm = glyphUnitsPerEm
        self.ptsPerGlyphUnits = ptsPerGlyphUnits
    }
    
    //let advances: [String: CGFloat]
    
    // points
    //let size: CGFloat
    //let pointsPerGlyphUnit: CGFloat
    
    func summary() -> String {
        var str = fontFamily.rawValue
        str = str.appending("\n")
        return str
    }
    
    func maxAscentCharacter() {
        fatalError("not implemented")
    }
    
    func getAdvances(string: String) -> (width: CGFloat, sizes: [CGSize])? {
        fatalError("not implemented")
    }
    
    func getBoundingRects(string: String) -> (overall: CGRect, list: [CGRect])? {
        fatalError("not implemented")
    }
    
    func getOpticalRects(string: String) -> (overall: CGRect, list: [CGRect])? {
        fatalError("not implemented")
    }

    func toValues(string: String) {
        var result = ""
        for utf32: Unicode.Scalar in string.unicodeScalars {
            if let metrics = lookup[utf32.value] {
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
    
    // MARK: - Class Methods 
    
    static func fileLoad(fontFamily: FontHelper.PostscriptName, fontSize: CGFloat) -> FontPointFamilyMetrics? {
        let filename = FontPointFamilyMetrics.toFilename(fontFamily: fontFamily, fontSize: fontSize)
        do {
            let url = fontmetricsDirUrl.appendingPathComponent(filename)
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let fontmetric = try decoder.decode(FontPointFamilyMetrics.self, from: data)
            return fontmetric
        } catch {
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
        } catch {
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
