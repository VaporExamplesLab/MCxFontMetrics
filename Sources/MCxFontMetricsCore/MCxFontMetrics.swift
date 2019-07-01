//
//  MCxFontMetrics.swift
//  MCxFontMetricsCore
//
//  Created by marc on 2019.06.30.
//

import Foundation

public final class MCxFontMetrics {
    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) { 
        self.arguments = arguments
    }

    public func run() throws {
        print("Hello world")
        
        let fontFamily = FontHelper.PostscriptName.gaugeRegular
        let fontSize: CGFloat = 12.0
        
        let extractor = try! FontMetricsExtractor(fontFamily: fontFamily, fontSize: fontSize)
        
        let fontMetric = FontPointFamilyMetrics(
            fontFamily: fontFamily, 
            fontSize: fontSize, 
            ptsAscent: extractor.ptsAscent(), 
            ptsDescent: extractor.ptsDescent(), 
            ptsLeading: extractor.ptsLeading(), 
            ptsCapHeight: extractor.ptsCapHeight(), 
            glyphUnitsPerEm: extractor.glyphUnitsPerEm(), 
            ptsPerGlyphUnits: extractor.ptsPerGlyphUnits())
        
        FontPointFamilyMetrics.fileSave(fontMetric)
        
        guard let fontMetric_In = FontPointFamilyMetrics.fileLoad(fontFamily: fontFamily, fontSize: fontSize) 
            else { return }
        
        print("Summary\n\(fontMetric_In.summary())")
    }
}

public extension MCxFontMetrics {
    enum Error: Swift.Error {
        case missingFirstArgument
        case failedToCreateFile
        case failedToDoSomething
        case fontNotFound
    }
}
