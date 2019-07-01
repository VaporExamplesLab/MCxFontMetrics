//
//  MCxFontMetrics.swift
//  MCxFontMetricsCore
//
//  Created by marc on 2019.06.30.
//

import Foundation

internal let fontmetricsDirUrl = URL(fileURLWithPath: "/opt/local/fontmetrics", isDirectory: true)

public final class MCxFontMetrics {
    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) { 
        self.arguments = arguments
    }

    public func run() throws {
        print("Hello world")
        
        let gaugeRegular = FontHelper.PostscriptName.gaugeRegular
        let fontMetric = FontMetric(font: gaugeRegular)
        
        FontMetric.fileSave(fontMetric)
        
        guard let fontMetric_In = FontMetric.fileLoad(font: gaugeRegular) 
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
