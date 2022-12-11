//: [Previous](@previous)

import Foundation

import PlaygroundSupport
import _Concurrency

PlaygroundPage.current.needsIndefiniteExecution = true

let day = 1

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
    
    let input = inputString
        .components(separatedBy: "\n\n")
        .map { $0.components(separatedBy: "\n") }
        /// Note: It is assumed that optional values can be discarded (eg. when using `components(separatedBy: "\n")`, the final element is `""` (when the original string terminates with `\n`), which is a result of how `components(separatedBy:)` behaves.
        .map { $0.compactMap { intString in Int(intString) } }
    
    // MARK: Part- 1
    let caloriesPerElf = input.map { $0.reduce(0, +) }
    
    guard let highestCalorieCount = caloriesPerElf.max() else { fatalError("Verify algorithm") }
    print("Largest calorie ⚡️ count for an 🧝‍♂️: \(highestCalorieCount)")
    
    // MARK: Part- 2
    let caloriesPerElfSorted = caloriesPerElf.sorted(by: >)
    let top3CalorieCount = caloriesPerElfSorted.prefix(3)
    print("Top🥇 3 🧝‍♂️ with largest calorie ⚡️ count: \(top3CalorieCount)")
    
    let top3CalorieCountAgg = top3CalorieCount.reduce(0, +)
    print("Accumulated calories ⚡️ count for Top🥇 3 🧝‍♂️ carrying the largest amount of calories: \(top3CalorieCountAgg)")
}

//: [Next](@next)
