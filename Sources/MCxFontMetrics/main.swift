import MCxFontMetricsCore

let tool = MCxFontMetrics()

do {
    try tool.run()
} catch {
    print("Whoops! An error occurred: \(error)")
}
