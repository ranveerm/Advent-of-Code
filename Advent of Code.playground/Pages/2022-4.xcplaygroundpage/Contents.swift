//: [Previous](@previous)

import Foundation

import PlaygroundSupport
import _Concurrency

PlaygroundPage.current.needsIndefiniteExecution = true

let day = 4

/// Helpers

/// Custom operator that encapsulates `⊆` (subset), but mirrors the operation on lhs and rhs (i.e. checks if lhs is a subset of rhs **OR** rhs is a subset of lhs)
infix operator ⊇⊆
extension ClosedRange {
    static func ⊇⊆(lhs: Self, rhs: Self) -> Bool {
        /*:
         - Reference: [Check if one Range is within another](https://stackoverflow.com/questions/64066681/check-if-one-range-is-within-another)
         */
        rhs.clamped(to: lhs) == rhs || lhs.clamped(to: rhs) == lhs
    }
}

extension Substring {
    var asClosedRange: ClosedRange<Int>? {
        let rangeElements = self.split(separator: "-")
        guard rangeElements.count == 2,
              let lowerBoundRaw = rangeElements.first,
              let lowerBound = Int(lowerBoundRaw),
              let upperBoundRaw = rangeElements.last,
              let upperBound = Int(upperBoundRaw) else { return nil }
        
        return lowerBound...upperBound
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
    let inputElfPairs = input.map { $0.split(separator: ",") }
    
    /// Models
    struct JobAssignmentPair {
        let elf1Sections: ClosedRange<Int>
        let elf2Sections: ClosedRange<Int>
        
        var completeOverlap: Bool { elf1Sections ⊇⊆ elf2Sections }
        var overlapExists: Bool {
            elf1Sections.overlaps(elf2Sections)
        }
        
        init?(_ elfPairsRaw: [ClosedRange<Int>]) {
            guard elfPairsRaw.count == 2,
                  let elf1Sections = elfPairsRaw.first,
                  let elf2Sections = elfPairsRaw.last else { return nil }
            
            self.elf1Sections = elf1Sections
            self.elf2Sections = elf2Sections
        }
    }
    
    /// Part-1
    let jobAssignmentPairs = inputElfPairs
        .map { $0.compactMap { sections in sections.asClosedRange } }
        .compactMap(JobAssignmentPair.init)
    
    let assignmentsWithFullyOverlappingRanges = jobAssignmentPairs
        .filter { $0.completeOverlap }
    
    print("Job assignment 🧹 pairs that have a complete overlap: \(assignmentsWithFullyOverlappingRanges.count)")
    
    /// Part-2
    let assignmentsWithOverlappingRanges = jobAssignmentPairs
        .filter { $0.overlapExists }
    
    print("Job assignment 🧹 pairs that have some overlap: \(assignmentsWithOverlappingRanges.count)")
}
//: [Next](@next)
