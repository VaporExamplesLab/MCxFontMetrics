//
//  FontMetric.swift
//  MCxFontMetricsCore
//
//  Created by marc on 2019.06.30.
//

import Foundation

/// Provides font character metrice for a given font and font size.
///
/// * Uses JSON encoding since an official BinaryEncode/BinaryDecoder does not exist at this time.
/// * Expects fontmetric files to be located in `/opt/local/fontmetrics`.
///
struct FontMetric: Codable {
    
    private let namePostscript: String
    //let boundingBox: [String:CGRect]
    
    init(font: FontHelper.PostscriptName) {
        self.namePostscript = font.rawValue
        
        
    }
    
    //let advances: [String: CGFloat]
    
    // points
    //let size: CGFloat
    //let pointsPerGlyphUnit: CGFloat
    
    func summary() -> String {
        var str = namePostscript
        str = str.appending("\n")
        return str
    }
    
    static func fileLoad(font: FontHelper.PostscriptName) -> FontMetric? {
        do {
            let url = fontmetricsDirUrl
                .appendingPathComponent("\(font.rawValue)_metrics")
                .appendingPathExtension("json")
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let fontmetric = try decoder.decode(FontMetric.self, from: data)
            return fontmetric
        } catch {
            print("ERROR: failed to load '\(font)_metrics.json' \n\(error)")
            return nil
        }
    }
    
    static func fileSave(_ fontmetric: FontMetric) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(fontmetric)
            let url = fontmetricsDirUrl
                .appendingPathComponent("\(fontmetric.namePostscript)_metrics")
                .appendingPathExtension("json")
            try data.write(to: url)
        } catch {
            print("ERROR: failed to save \(fontmetric.namePostscript)_metrics.json \n\(error)")
        }
    }
    
    
}
