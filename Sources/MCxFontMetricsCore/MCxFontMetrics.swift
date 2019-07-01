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
        // Fonts used by labels.
        processOneFont(fontFamily: .gaugeRegular, fontSize: 12.0)
        processOneFont(fontFamily: .gaugeHeavy, fontSize: 12.0)
        processOneFont(fontFamily: .dejaVuCondensed, fontSize: 12.0)
        processOneFont(fontFamily: .mswImpact, fontSize: 12.0)
        processOneFont(fontFamily: .dejaVuMono, fontSize: 12.0)
        processOneFont(fontFamily: .liberationNarrow, fontSize: 12.0)

        // Font size 48.0 used used to generate FontMetricsPage.
        processOneFont(fontFamily: .gaugeRegular, fontSize: 48.0)
        processOneFont(fontFamily: .gaugeHeavy, fontSize: 48.0)
        processOneFont(fontFamily: .dejaVuCondensed, fontSize: 48.0)
        processOneFont(fontFamily: .mswImpact, fontSize: 48.0)
        processOneFont(fontFamily: .dejaVuMono, fontSize: 48.0)
        processOneFont(fontFamily: .liberationNarrow, fontSize: 48.0)
    }
    
    internal func processOneFont(fontFamily: FontHelper.PostscriptName, fontSize: CGFloat) {
        let extractor = try! FontMetricsExtractor(fontFamily: fontFamily, fontSize: fontSize)
        let lookupMap = extractor.createUTF32MetricsMap()
        
        let fontMetric = FontPointFamilyMetrics(
            fontFamily: fontFamily, 
            fontSize: fontSize, 
            ptsAscent: extractor.ptsAscent(), 
            ptsDescent: extractor.ptsDescent(), 
            ptsLeading: extractor.ptsLeading(), 
            ptsCapHeight: extractor.ptsCapHeight(), 
            glyphUnitsPerEm: extractor.glyphUnitsPerEm(), 
            ptsPerGlyphUnits: extractor.ptsPerGlyphUnits(),
            lookup: lookupMap
        )
        
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
