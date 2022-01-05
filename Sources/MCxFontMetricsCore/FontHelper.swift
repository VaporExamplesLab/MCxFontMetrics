//
//  FontHelper.swift
//  MCxPrintCore
//
//  Created by marc on 2019.06.14.
//

import Foundation
import CoreText

public struct FontHelper {
    
    /// Fonts which can be freely installed on Apple & Linux OS systems
    ///
    /// Shell:
    /// ```sh
    /// for file in "$arg"*.{ttf,otf};
    ///   do fc-scan --format "%{postscriptname}\n" "$file";
    /// done
    /// ```
    ///
    /// Regex: find: `(^.*$)` replace: case `$1 = "$1"`
    ///
    public enum PostscriptName: String, Codable {
        /// DejaVu Condensed Mono
        case dejaVuCondensed = "DejaVuSansCondensed"
        case dejaVuCondensedBold = "DejaVuSansCondensed-Bold"
        case dejaVuCondensedBoldOblique = "DejaVuSansCondensed-BoldOblique"
        case dejaVuCondensedOblique = "DejaVuSansCondensed-Oblique"
        
        /// DejaVu Sans Mono
        ///
        /// **Attributes**
        /// * PostScript name: DejaVuSansMono
        /// * Full name: DejaVu Sans Mono
        /// * Family: DejaVu Sans Mono
        /// * Style: Book
        /// * Kind: OpenType TrueType
        /// * Unique name: DejaVu Sans Mono
        case dejaVuMono = "DejaVuSansMono"
        case dejaVuMonoBold = "DejaVuSansMono-Bold"
        case dejaVuMonoBoldOblique = "DejaVuSansMono-BoldOblique"
        case dejaVuMonoOblique = "DejaVuSansMono-Oblique"
        
        /// DejaVu Condensed Sans
        case dejaVuSans = "DejaVuSans"
        case dejaVuSansBold = "DejaVuSans-Bold"
        case dejaVuSansBoldOblique = "DejaVuSans-BoldOblique"
        case dejaVuSansExtraLight = "DejaVuSans-ExtraLight"
        case dejaVuSansOblique = "DejaVuSans-Oblique"
        
        /// DejaVu Condensed Serif
        case dejaVuSerif = "DejaVuSerif"
        case dejaVuSerifBold = "DejaVuSerif-Bold"
        case dejaVuSerifBoldItalic = "DejaVuSerif-BoldItalic"
        case dejaVuSerifItalic = "DejaVuSerif-Italic"
        case dejaVuSerifCondensedBold = "DejaVuSerifCondensed-Bold"
        case dejaVuSerifCondensedBoldItalic = "DejaVuSerifCondensed-BoldItalic"
        case dejaVuSerifCondensedItalic = "DejaVuSerifCondensed-Italic"
        case dejaVuSerifCondensed = "DejaVuSerifCondensed"
        
        // https://github.com/liberationfonts/liberation-fonts/releases
        // https://github.com/liberationfonts/liberation-sans-narrow/releases
        
        /// Liberation Mono monospace (Courier New metric)
        case liberationMono = "LiberationMono"
        /// Liberation Mono Bold monospace (Courier New metric)
        case liberationMonoBold = "LiberationMono-Bold"
        /// Liberation Mono Bold Italic monospace (Courier New metric)
        case liberationMonoBoldItalic = "LiberationMono-BoldItalic"
        /// Liberation Italic monospace (Courier New metric)
        case liberationMonoItalic = "LiberationMono-Italic"
        
        /// Liberation Sans Arial Metric
        case liberationSans = "LiberationSans"
        case liberationSansBold = "LiberationSans-Bold"
        case liberationSansBoldItalic = "LiberationSans-BoldItalic"
        case liberationSansItalic = "LiberationSans-Italic"
        
        /// Liberatin Serif (New York Times metric)
        case liberationSerif = "LiberationSerif"
        case liberationSerifBold = "LiberationSerif-Bold"
        case liberationSerifBoldItalic = "LiberationSerif-BoldItalic"
        case liberationSerifItalic = "LiberationSerif-Italic"
        
        /// Liberation Sans Narrow (Arial Narrow metric)
        case liberationNarrow = "LiberationSansNarrow"
        case liberationNarrowBold = "LiberationSansNarrow-Bold"
        case liberationNarrowBoldItalic = "LiberationSansNarrow-BoldItalic"
        case liberationNarrowItalic = "LiberationSansNarrow-Italic"
        
        /// Microsoft Web Font: Impact
        case mswImpact = "Impact"
        
        /// Gauge small caps.
        ///
        /// **See Also** 
        /// [FontLibrary: Gauge ⇗](https://fontlibrary.org/en/font/gauge)
        case gaugeRegular = "Gauge-Regular"
        /// Gauge small caps italics.
        case gaugeOblique = "Gauge-Oblique"
        /// Gauge small caps bold.
        case gaugeHeavy = "Gauge-Heavy"
    }
    
    /// Fonts specific to Apple installations
    enum nameApple: String {
        case andaleMono = "AndaleMono"
        case appleChancery = "Apple-Chancery"
        case appleGothic = "AppleGothic"
        
        case arial = "ArialMT"
        case arialBoldItalic = "Arial-BoldItalicMT"
        case arialBold = "Arial-BoldMT"
        case arialItalic = "Arial-ItalicMT"
        
        case arialBlack = "Arial-Black"
        case arialNarrowBoldItalic = "ArialNarrow-BoldItalic"
        case arialNarrowBold = "ArialNarrow-Bold"
        case arialNarrowItalic = "ArialNarrow-Italic"
        case arialNarrow = "ArialNarrow"
        case arialRoundedBold = "ArialRoundedMTBold"
        case arialUnicode = "ArialUnicodeMS"
        
        case bradleyHand = "BradleyHandITCTT-Bold"
        case brushScript = "BrushScriptMT"
        case chalkduster = "Chalkduster"
        
        case chintzyCPUBRK = "ChintzyCPUBRK"
        case chintzyCPUShadowBRK = "ChintzyCPUShadowBRK"
        
        case comicSansBold = "ComicSansMS-Bold"
        case comicSans = "ComicSansMS"
        
        // macOS, Ubuntu
        case dejaVuMathTeXGyreRegular = "DejaVuMathTeXGyre-Regular"
        
        
        case herculanum = "Herculanum"
        
        case impact = "Impact"
        
        case noteworthyLight = "Noteworthy-Light"
        case noteworthyBold = "Noteworthy-Bold"
        
        case ptDingbats3 = "PTDingbats3"
        case ptDingbats4 = "PTDingbats4"
        case ptFrameMac = "PTFrameMac"
        
        case webdings = "Webdings"
        case wingdings2 = "Wingdings2"
        case wingdings3 = "Wingdings3"
        case wingdingsRegular = "Wingdings-Regular"
        case zapfino = "Zapfino"
        
    }
    
    
    /// Font Family Name
    ///
    /// [MDN font-family](https://developer.mozilla.org/en-US/docs/Web/CSS/font-family)
    enum nameFull: String {
        
        case arial = "Arial" // "ArialMT"
        case arialItalic = "Arial Italic" // "Arial-ItalicMT"
        case arialBold = "Arial Bold" // "Arial-BoldMT"
        case arialBoldItalic = "Arial Bold Italic"
        case arialNarrow = "Arial Narrow"
        case arialNarrowItalic = "Arial Narrow Italic"
        case arialNarrowBold = "Arial Narrow Bold"
        case arialNarrowBoldItalic = "Arial Narrow Bold Italic"
        case arialBlackRegular = "Arial Black Regular"
        case arialRoundedMTBoldRegular = "Arial Rounded MT Bold Regular"
        
        /// DejaVu Sans Markup
        ///
        /// **Features:**
        /// * Slightly modified for markup languages such as LaTeX, Asciidoc, or markdown.
        ///     * modified endash to distinguish from hyphen
        ///     * modified minus sign to distinguish from the endash.
        /// * DejaVu Uppercase J, Q drop below baseline.
        /// * Based on DejaVu Sans Mono
        case dejaVuMarkup = "DejaVu Markup"
        case dejaVuMarkupOblique = "DejaVu Markup Oblique"
        case dejaVuMarkupBold = "DejaVu Markup Bold"
        case dejaVuMarkupBoldOblique = "DejaVu Markup Bold Oblique"
        
        case dejaVuSans = "DejaVu Sans"
        case dejaVuSansExtraLight = "DejaVu Sans ExtraLight"
        case dejaVuSansOblique = "DejaVu Sans Oblique"
        case dejaVuSansBold = "DejaVu Sans Bold"
        case dejaVuSansBoldOblique = "DejaVu Sans Bold Oblique"
        case dejaVuSansCondensed = "DejaVu Sans Condensed"
        case dejaVuSansCondensedOblique = "DejaVu Sans Condensed Oblique"
        case dejaVuSansCondensedBold = "DejaVu Sans Condensed Bold"
        case dejaVuSansCondensedBoldOblique = "DejaVu Sans Condensed Bold Oblique"
        
        /// DejaVu Sans Mono
        ///
        /// **Attributes:**
        /// * PostScript name: DejaVuSansMono
        /// * Full name: DejaVu Sans Mono
        /// * Family: DejaVu Sans Mono
        /// * Style: Book
        /// * Kind: OpenType TrueType
        /// * Unique name: DejaVu Sans Mono
        case dejaVuMono = "DejaVu Sans Mono" // "DejaVuSansMono"
        case dejaVuMonoOblique = "DejaVu Sans Mono Oblique"
        case dejaVuMonoBold = "DejaVu Sans Mono Bold"
        case dejaVuMonoBoldOblique = "DejaVu Sans Mono Bold Oblique"
        
        case noteworthyLight = "Noteworthy Light"
        case noteworthyBold = "Noteworthy Bold"
        
    }
    
    /// Use either the font's PostScript name or full name
    static func getCTFont(fontFamily: FontHelper.PostscriptName, fontsize: CGFloat) -> CTFont? {
        let cfsFontName: CFString = fontFamily.rawValue as CFString
        
        guard let cgFont = CGFont(cfsFontName) else {
            return nil
        }
        
        let ctFont: CTFont = CTFontCreateWithGraphicsFont(
            cgFont,   // graphicsFont: CGFont
            fontsize, // size: CGFloat. 0.0 defaults to 12.0
            nil,      // matrix: UnsafePointer<CGAffineTransforms>?
            nil       // attributes: CTFontDescriptor?
        )
        
        return ctFont
    }
    
    // * DejaVu was the GNOME default.
    // * Cantarell is the GNOME 3+ default.
    //
    // * Oxygen is a KDE font.
    //
    // *  Noto has broad multilingual support.
    //
    // * Liberation. Often installed with LibreOffice.
    // * Croscore. Calibri and Cambria substitutes are available in Croscore Extra.
    // * TeXGyre. Based on originals by URW.
    
}
