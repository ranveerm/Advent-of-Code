//: [Previous](@previous)

import Foundation

import PlaygroundSupport
import _Concurrency

PlaygroundPage.current.needsIndefiniteExecution = true

let day = 0

Task {
    // MARK: Input Retrieval
    let rawInput: Data
    
    do { rawInput = try await InputManager.fetchInput(day: day) }
    catch {
        if let error = error as? InputManager.Error { fatalError(error.localizedDescription) }
        fatalError("Unknown error when fetching input")
    }
    
    // MARK: Input Processing
    guard let inputString = String(data: rawInput, encoding: .utf8) else { fatalError("Unable to decode input using UTF8") }
    print(inputString)
}

//: [Next](@next)
