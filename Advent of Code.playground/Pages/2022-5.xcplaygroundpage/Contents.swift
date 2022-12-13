//: [Previous](@previous)

import Foundation

import PlaygroundSupport
import _Concurrency
import RegexBuilder

PlaygroundPage.current.needsIndefiniteExecution = true

let day = 5

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
    
    let input = inputString.split(separator: "\n\n")
    
    guard input.count == 2,
          let initialCrateConfiguration = input.first,
          let rearrangementProcedure = input.last else { fatalError("Input is in an unexpected format") }
    
    guard let finalStackLabel = initialCrateConfiguration
        .split(separator: "\n")
        .last?
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .last,
          let numberOfStacks = finalStackLabel.wholeNumberValue else { fatalError("Input is in an unexpected format") }
    
    let distanceBetweenStacks = 4 /// Obtained from inspection of `initialCrateConfiguration`
    
    let initialLabelOffset = 1/// Start index is 1 as the first element is either ` ` or `[`
    let finalStackLabelLocation = (numberOfStacks - 1) * distanceBetweenStacks + initialLabelOffset
    let stackLabelLocations = stride(from: initialLabelOffset,
                                     through: finalStackLabelLocation,
                                     by: distanceBetweenStacks)
    
    var stacks = stackLabelLocations.map { _ in "" }
    initialCrateConfiguration
        .split(separator: "\n")
        .dropLast() /// Last row denotes stack index
        .forEach { cratesInRow in
            stackLabelLocations
                .enumerated()
                .forEach { stackLabel, stackLabelLocation in
                    let locationOfCrate = cratesInRow.index(cratesInRow.startIndex, offsetBy: stackLabelLocation)
                    let crate = String(cratesInRow[locationOfCrate]).trimmingCharacters(in: .whitespaces)
                    
                    /// Note order of crate insertion
                    stacks[stackLabel] = crate + stacks[stackLabel]
                }
        }

    let regex = Regex {
        ZeroOrMore(.whitespace)
        Capture {
            ChoiceOf {
                "move"
                "from"
                "to"
            }
        }
        One(.whitespace)
    }
    
    let rearrangementProcedureNumerical = rearrangementProcedure
        .split(separator: "\n")
        .map { $0.split(separator: regex) }
        .map { $0.compactMap { integerAsString in Int(integerAsString)  } }
    
    /// Models
    struct RearrangementProcedure {
        let numberOfCratesToMove: Int
        let sourceStack: Int
        let destinationStack: Int
        
        /// Important- be wary of 0-indexing
        init?(_ inputArray: [Int]) {
            guard inputArray.count == 3 else { return nil }
            
            self.numberOfCratesToMove = inputArray[0]
            self.sourceStack = inputArray[1] - 1
            self.destinationStack = inputArray[2] - 1
        }
    }
    
    enum Crane {
        case crateMover9000
        case crateMover9001
    }
    
    class CraseStackInventory {
        var stacks: [String]
        
        init(_ stacks: [String]) {
            self.stacks = stacks
        }
        
        func moveCrates(using crane: Crane, procedure: RearrangementProcedure) {
            /// Note- the source stack is used several time throughout this method. However, usage varies from inspection to mutation. The below snapshot value must only be used during inspection.
            let sourceStackSnapshot = stacks[procedure.sourceStack]
            /// Note- It might be possible for some stacks to contan no crates.
            guard !sourceStackSnapshot.isEmpty else { return }
            let numberOfCratesToMove = min(sourceStackSnapshot.count, procedure.numberOfCratesToMove)
            
            var cratesToMove = ""
            
            switch crane {
            case .crateMover9000:
                /// Note- due to the nature of below operations, `cratesToMove` contains the relevant crates from the source in reverese order, which is desirable.
                (0..<numberOfCratesToMove).forEach { _ in
                    cratesToMove.append(stacks[procedure.sourceStack].removeLast())
                }
                
            case .crateMover9001:
                let locationOfTopCrate = sourceStackSnapshot.endIndex
                let locationOfBottomCrateToRemove = sourceStackSnapshot.index(locationOfTopCrate, offsetBy: procedure.numberOfCratesToMove * -1)
                let locationOfCratesToRemove = locationOfBottomCrateToRemove..<locationOfTopCrate
                
                cratesToMove = String(sourceStackSnapshot[locationOfCratesToRemove])
                stacks[procedure.sourceStack].removeSubrange(locationOfCratesToRemove)
            }
            
            stacks[procedure.destinationStack].append(cratesToMove)
        }
        
        func cratesAtTopOfStacks() -> String {
            stacks
                /// Note- if a stack contains no crates, it is ignored
                .compactMap { $0.last }
                .map(String.init)
                .reduce("", +)
        }
    }
    
    /// Part-1
    var crateStackInventory = CraseStackInventory(stacks)
    let rearrangementProcedures = rearrangementProcedureNumerical
        .compactMap(RearrangementProcedure.init)
    
    rearrangementProcedures.forEach { crateStackInventory.moveCrates(using: .crateMover9000, procedure: $0) }
    
    var cratesAtTopOfStacks = crateStackInventory.cratesAtTopOfStacks()
    
    print("Crates 📦 at top of stacks: \(cratesAtTopOfStacks)")
    
    /// Part-2
    crateStackInventory = CraseStackInventory(stacks)
    
    rearrangementProcedures.forEach { crateStackInventory.moveCrates(using: .crateMover9001, procedure: $0) }
    
    cratesAtTopOfStacks = crateStackInventory.cratesAtTopOfStacks()
    
    print("Crates 📦 at top of stacks: \(cratesAtTopOfStacks)")
}

//: [Next](@next)
