import Foundation
import XCTest

// testable attribute allows access to `internal` scope items for internal framework testing.
@testable 
import MCxFontMetricsCore

final class MCxFontMetricsTests: XCTestCase {
    
    func terminationExample(process: Process, expectation: XCTestExpectation) {
        DispatchQueue.main.async {
            print("•••ENTER••• terminationExample dispatch")
            let taskStatus = process.terminationStatus
            
            if (taskStatus == 0) {
                debugPrint("Pass: terminationExample() task completed sucessfully!")
                expectation.fulfill()
            } else {
                debugPrint("Fail: terminationExample() task did not complete.")
            }
            print("•••EXIT••• terminationExample dispatch")
        }
    }
    
    func testExecutable() throws {
        print("\n######################")
        print("## testExecutable() ##")
        print("######################")
        
        // Some APIs used require macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return
        }
        
        // Create an expectation for a background task.
        let expectation = XCTestExpectation(description: "Some background task.")
        
        
        // build products directory
        let executableUrl = productsDirectory.appendingPathComponent("MCxFontMetrics")
        
        // https://developer.apple.com/documentation/foundation/process
        let process = Process()
        process.executableURL = executableUrl
        
        var arguments = [String]()
        arguments.append("-flag")
        arguments.append("--param1=value1")
        arguments.append(contentsOf: ["--param2=value2", "-other-flag"])
        process.arguments = arguments
        
        process.terminationHandler = { 
            (task: Process) -> Void in
            print("•••ENTER••• terminationHandler")
            self.terminationExample(process: task, expectation: expectation)
            print("•••EXIT••• terminationHandler")
        }
        
        let stdoutPipe = Pipe()
        process.standardOutput = stdoutPipe
        let stderrPipe = Pipe()
        process.standardError = stderrPipe
        
        try process.run()
        
        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        if let stdoutStr = String(data: stdoutData, encoding: .utf8) {
            print("\n## stdOutput\n\(stdoutStr)")
            XCTAssert(stdoutStr.contains("Hello"))
        }
        else {
            throw MCxFontMetrics.Error.failedToDoSomething
        }
        
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        if let stderrStr = String(data: stderrData, encoding: String.Encoding.utf8) {
            print("\n## stdError\n\(stderrStr)")
        }
        else {
            throw MCxFontMetrics.Error.failedToDoSomething
        }
        
        process.waitUntilExit()
        let status: Int32 = process.terminationStatus
        print("## TERMINATION STATUS: \(status)")
        
        let reason: Process.TerminationReason = process.terminationReason
        print("## TERMINATION REASON: \(reason.rawValue) (.exit==1, .uncaughtSignal==2)")
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFramework() throws {
        print("\n#####################")
        print("## testFramework() ##")
        print("#####################")
        
        // Create an instance of the command line tool framework
        var arguments = [String]()
        arguments.append("-flag")
        arguments.append("--param1=value1")
        arguments.append(contentsOf: ["--param2=value2", "-other-flag"])
        let tool = MCxFontMetrics(arguments: arguments)
        
        // Run the tool and assert that the file was created
        do {
            try tool.run()
            
            // Check some outcome
            //XCTAssertNotNil(try? testFolder.file(named: "Hello.swift"))
        } 
        catch {
            throw MCxFontMetrics.Error.failedToDoSomething
        }
    }
    
    func testWorkwrap() {
        let fontFamily = FontHelper.PostscriptName.dejaVuMono
        let fontSize: CGFloat = 12.0
        guard let fontMetric = FontPointFamilyMetrics.fileLoad(fontFamily: fontFamily, fontSize: fontSize) 
            else { 
                XCTFail("testWorkwrap() could not load font \(fontFamily) \(fontSize)") 
                return
        }
        
        let string = "supercaliflawjalisticexpialadoshus a b c d e f g h i j k l m n o p Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. supercaliflawjalisticexpialadoshus"
        
        let lines = fontMetric.wordwrap(string: string, width: 200.0)
        for l in lines {
            print(l)
        }
        
        XCTAssert(lines.count == 9)
    }
    
    /// Returns path to the built products directory.
    var productsDirectory: URL {
        #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
        #else
        return Bundle.main.bundleURL
        #endif
    }
    
    func testProductsDirectory() {
        print("\n#############################")
        print("## testProductsDirectory() ##")
        print("#############################\n")
        
        print("productsDirectory = '\(productsDirectory)'")
        
    }
    
    static var allTests = [
        ("testExample", testExecutable),
        ("testExample", testFramework),
        ("testWorkwrap", testWorkwrap),
        ("testProductsDirectory", testProductsDirectory),
        ]
}
