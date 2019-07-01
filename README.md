# MCxFontMetrics

<a id="toc"></a>
[Original Setup](#linkOriginalProjectSetup) • 
[Resources](#linkResources) 

**Options:**

```sh
mcxfontmetrics --font-name=DejaVuSansMono

# DejaVuSansMono
```

Generate an Xcode project.

``` sh
swift package update
swift package generate-xcodeproj --xcconfig-overrides Package.xcconfig
```


## Original Project Setup <a id="linkOriginalProjectSetup"></a>[▴](#toc)

Summary of original steps used to create the MCxFontMetrics example template.

``` sh
mkdir MCxFontMetrics
cd MCxFontMetrics
swift package init --type executable

# review & update .gitignore, as needed
nano .gitignore
```

**Framework & Executable Modules**

Create two modules: one framework `MCxFontMetrics` and one executable `MCxFontMetricsCore`. Each top level folder under `Sources` defines a module.

The executable module only contains the `main.swift` file. The core framework contains all of the tool’s actual functionality.  The separation of the core framework provides for *easier testing*; and, the *core framework can be used as a dependency in other executables*.

``` sh
// create core framework module
mkdir Sources/MCxFontMetricsCore
```

Update `Package.swift` to define two targets — one for the `MCxFontMetrics` executable module and one for the `MCxFontMetricsCore` framework.

``` sh
# edit Package.swift
nano Package.swift
```

_Package.swift_

``` swift
import PackageDescription

let package = Package(
    name: "MCxFontMetrics",
    // ...
    targets: [
        .target(
            name: "MCxFontMetrics",
            dependencies: ["MCxFontMetricsCore"]),
        .target(
            name: "MCxFontMetricsCore",
            dependencies: []),
        // Test MCxFontMetricsCore directly instead of MCxFontMetrics main.swift
        .testTarget(
            name: "MCxFontMetricsTests",
            dependencies: ["MCxFontMetricsCore"]),
        // ...
    ]
)
```

**Define Programmatic Entry Point**

Create a new MCxFontMetrics.swift core framework class.

``` sh
# nano Sources/MCxFontMetricsCore/MCxFontMetrics.swift
touch Sources/MCxFontMetricsCore/MCxFontMetrics.swift
edit Sources/MCxFontMetricsCore/MCxFontMetrics.swift 
```

``` swift
import Foundation

public final class MCxFontMetrics {
    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) { 
        self.arguments = arguments
    }

    public func run() throws {
        print("Hello world")
    }
}
```

Update Sources/MCxFontMetrics/main.swift to call the `run()` method which is in the core framework MCxFontMetrics class.

``` sh
# nano Sources/MCxFontMetrics/main.swift
edit Sources/MCxFontMetrics/main.swift
```


``` swift
import MCxFontMetricsCore

let tool = MCxFontMetrics()

do {
    try tool.run()
} catch {
    print("Whoops! An error occurred: \(error)")
}
```

**Xcode**

``` sh
# edit Package.xcconfig 
nano Package.xcconfig
```

``` ini
/// macOS Deployment Target
MACOSX_DEPLOYMENT_TARGET=10.13

// Swift Language Version
// 
SWIFT_VERSION = 4.2
```

Generate an Xcode project.

``` sh
swift package update
swift package generate-xcodeproj --xcconfig-overrides Package.xcconfig
```

**Run**

``` sh
swift build
.build/debug/MCxFontMetrics
# Hello World
```

**Test**

The `MCxFontMetricsCore` framework can be tested directly. Or, a `Process` can be run to test the `MCxFontMetrics` executable.

_Command Line Tests_


``` sh
## runs 'All tests'
## path .build/architecture/debug/MCxFontMetrics
swift test
```

_Xcode Testing_

Runs 'Selected Tests'. Execution path: .../DerivedData/MCxFontMetrics-id/Build/Products/Debug/MCxFontMetrics

**Installation**

To run the CLI tool from anywhere, move the executable command to some path which is present on the `$PATH` environment variable. For example, move the the compiled binary to `/usr/local/bin` or `/opt/local/bin`.

> Note: On macOS, `brew doctor` may complain about file in `/usr/local/bin` which are not managed by Homebrew. 

``` sh
swift build --configuration release
```

_macOS_

``` sh
# Linking ./.build/x86_64-apple-macosx10.10/release/MCxFontMetrics
cd .build/x86_64-apple-macosx10.10/release

sudo mkdir -p /opt/local/bin
// -f force overwrite of existing file
cp -f MCxFontMetrics /opt/local/bin/MCxFontMetrics
```

_Ubuntu_

``` sh
# Linking ./.build/x86_64-apple-macosx10.10/release/MCxFontMetrics

cd .build/release
#cp -f MCxFontMetrics /usr/local/bin/MCxFontMetrics
cp -f MCxFontMetrics /opt/local/bin/MCxFontMetrics
```

## Resources <a id="linkResources"></a>[▴](#toc)
