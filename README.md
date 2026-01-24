# Repellent

Repellent is a ridiculously simple and easy-to-use debugger for Swift.

<p>
  <a href="https://swift.org/"><img src="https://img.shields.io/badge/Swift-6.2-orange.svg" alt="Swift 6.2"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT"></a>
</p>

---

## How does it work?

Repellent is a single class of static functions—for console logging, profiling, and catching throw errors—all synchronized to the same counter and timestamp objects, so you can see the exact order of debugger logs across every file in project.

## Installation

### Swift Package Manager

1. Go to <b>File → Add Package Dependencies...</b>
2. Type in ```https://github.com/keublitz/Repellent```
3. Selected the latest version

## Usage

> Use the shared ```console``` object to call all functions.

## ```log()```

This function works nearly identically to Swift's default ```print()```, but has a built in log counter, timestamps, and exact location where the log was called from.

### Default usage
```swift
import Repellent
import SwiftUI

struct ContentView: View {
    @State private var amount: Int = 0

    private func addOne() {
        amount += 1
        console.log("Amount increased by one!")
    }

    var body: some View {
        Button("Add one") {
            addOne()
        }
    }
}
```
<b>Console:</b>
```
001 | 09:41:00 | [ContentView.addOne.7] Amount increased by one!
```
### Labelling
You can also specify the category of the log, such as ```.success```, ```.error```, or an explicit ```.debug``` clarification.

```swift
import Repellent
import SwiftUI

struct ContentView: View {
    @State private var amount: Int = 0

    private func addOne() {
        amount += 1
        console.log("Amount increased by one!", type: .success)
        console.log("Current count:", amount, type: .info)
    }

    var body: some View {
        Button("Add one") {
            addOne()
        }
    }
}
```
```
001 | 09:41:00 | [ContentView.addOne.7] SUCCESS: Amount increased by one!
002 | 09:41:00 | [ContentView.addOne.7] INFO: Current count: 1
```
> The category is set to ```.none``` by default, producing no label.

### Simple layout
For continuous statements or any statements you want to keep as simple as possible, set the ```simple:``` modifier to TRUE in order to remove any text after the counter and timestamp.

```swift
var body: some View {
    Button("Add one") {
        addOne()
    }
    .onAppear {
        console.log("Button is now visible", simple: true)
    }
}
```
```
001 | 09:41:00 | Button is now visible
```

## ```profile()```

This function profiles the total duration of an operation in milliseconds. Simply wrap it around the block of code you want to monitor, and Repellent will send the statement at the end of execution.

```swift
import SwiftUI
import Repellent

struct ContentView: View {
    private var largeArray: [Int] = Array(1...10000)

    private func processArray() -> [Int] {
        console.profile {
            return largeArray.map { item in
                var result = item
                for _ in 0..<10000 {
                    result = result * 2 % 1000
                }
                return result
            }
            .filter { $0 > 500 }
            .sorted()
        }
    }

    var body: some View {
        Button("Process array") {
            processArray()
            console.log("Array is processed!", type: .success)
        }
    }
}

```
```
001 | 09:41:00 | [ContentView.processArray] *** Executed task in 3.41ms ***
002 | 09:41:00 | [ContentView.body.26] SUCCESS: Array is processed!
```

## ```guardBlocked()```

This function is designed to send a log when ```guard``` statement is not met.

```swift
import SwiftUI
import Repellent

struct ContentView: View {
    @State private var text: String? = nil
    @State private var showingText: Bool = false

    private func showText() {
        guard let text else {
            console.guardBlocked()
            return
        }

        showingText = true
    }

    var body: some View {
        if let text, showingText {
            Text(text)
        }

        Button("Show text") {
            showText()
        }
    }
}
```
```
001 | [ContentView.showText.8] BLOCKED: Function did not pass guard
```

For more verbosity, a reason for the block can be added.

```swift
private func showText() {
    guard let text else {
        console.guardBlocked(because: "text does not exist")
        return
    }

    showingText = true
}
```
```
001 | [ContentView.showText.8] BLOCKED: Function did not pass guard (text does not exist)
```

## ```catch()```

This function is designed to catch thrown errors.

```swift
import SwiftUI
import Repellent

struct Decoder {
    let stringURL: URL
    var numbers: [Int] = []

    private func decodeNumbers() {
        do {
            let data = try Data(contentsOf: stringURL)
            numbers = try JSONDecoder().decode(Int.self, from: data)
        } catch {
            console.catch(error)
        }
    }
}
```
```
001 | 09:41:00 | [Decoder.decodeNumbers.8] ERROR: The data couldn't be read because it isn't in the correct format.
==> typeMismatch(Swift.Int, Swift.DecodingError.Context(codingPath: [], debugDescription: "Expected to decode Int but found a string/data instead.", underlyingError: nil))
```

All error data is printed by default, but you can print only the localized description by setting the ```context``` modifier to FALSE.

```swift
catch {
    console.catch(error, context: false)
}
```

## ```fatalError()```

Works identically to Swift's default ```fatalError()``` but includes the counter and timestamp by default.

```swift
init() {
    guard let resource = Bundle.main.path(forResource: "resource", ofType: nil) else {
        console.fatalError("Bundle not found")
    }
}
```
```
001 | 09:41:00 | [LoremIpsum.init.5] FATAL ERROR: Bundle not found
```

And unlike the Swift default, Repellent's ```fatalError()``` supports <b>```Any```</b> within the message descriptor, so you can print more than just ```String``` values.

```swift
init(value: Double) {
    self.value = value

    if value > 255 {
        console.fatalError("Overflow value:", value)
    }
}
```
```
001 | 09:41:00 | [LoremIpsum.init.5] FATAL ERROR: Overflow value: 267
```

## License
Repellent is available under the MIT license. See the LICENSE file for more info.
