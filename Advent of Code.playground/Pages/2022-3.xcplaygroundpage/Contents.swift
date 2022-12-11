//: [Previous](@previous)
import Foundation

import PlaygroundSupport
import _Concurrency

PlaygroundPage.current.needsIndefiniteExecution = true

let day = 3

// MARK: Helpers
extension String {
    var uniqueCharacters: Set<Character> { Set(Array(self)) }
}

extension Character {
    var rucksackItemPriority: Int? {
        let asciiOffset = self.isUppercase ? 38 : 96
        guard let asciiValue = asciiValue else { return nil }
        return Int(asciiValue) - asciiOffset
    }
}

/// Note: The below chuncking logic should be geenralised across `Element`, as opposed to being specific to `String`
extension Array<String>.SubSequence {
    func chunked(_ chunkSize: Int) -> [[Element]] {
        stride(from: 0, to: count, by: chunkSize).map {
            Array(self[$0..<($0 + chunkSize)])
        }
    }
}

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
    
    let input = inputString.components(separatedBy: "\n").dropLast(1)
    
    // MARK: Models
    struct RuckSack {
        let compartment1: String
        let compartment2: String
        
        init?(_ items: String) {
            let compartmentSize = items.count / 2
            
            let startIndex = items.startIndex
            let middleIndex = items.index(startIndex, offsetBy: compartmentSize)
            
            let compartment1 = items[startIndex..<middleIndex]
            let compartment2 = items[middleIndex..<items.endIndex]
            guard compartment1.count == compartment2.count else { return nil }
            
            self.compartment1 = String(compartment1)
            self.compartment2 = String(compartment2)
        }
        
        func itemInBothCompartments() -> Character? {
            let matchedItems = compartment1.uniqueCharacters.intersection(compartment2)
            
            guard matchedItems.count == 1,
                  let matchedItem = matchedItems.first else { return nil }
            
            return matchedItem
        }
    }
    
    struct ElfGroup {
        static let groupSize = 3
        let ruckSacks: [RuckSack]
        let group: Character
        
        init?(_ ruckSacksRaw: [String]) {
            self.ruckSacks = ruckSacksRaw.compactMap(RuckSack.init)

            guard ruckSacks.count == Self.groupSize else { return nil }
            
            let uniqueItemsWithinRuckSackCollection = ruckSacksRaw
                .map { $0.uniqueCharacters }

            let itemsAcrossAllruckSacks = uniqueItemsWithinRuckSackCollection
                .dropFirst()
                .reduce(uniqueItemsWithinRuckSackCollection[0]) { $0.intersection($1) }
            
            guard itemsAcrossAllruckSacks.count == 1,
                  let group = itemsAcrossAllruckSacks.first else { return nil }
            
            self.group = group
        }
    }
    
    // Part-1
    let priorityAggregated = input
        .compactMap(RuckSack.init)
        .compactMap { $0.itemInBothCompartments() }
        .compactMap { $0.rucksackItemPriority }
        .reduce(0, +)
    
    print("Aggregated priority 🧾: \(priorityAggregated)")
    
    // Part-2
    let groupPriorityAggregated = input
        .chunked(ElfGroup.groupSize)
        .compactMap(ElfGroup.init)
        .compactMap { $0.group.rucksackItemPriority }
        .reduce(0, +)
    
    print("Aggregated gourp 🧝‍♂️🧝🧝‍♀️ priority 🧾: \(groupPriorityAggregated)")
    
}

//: [Next](@next)
