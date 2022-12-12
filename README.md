# 🎄 Advent-of-Code 🎄
Responses to [Advent of Code](https://adventofcode.com/2022/about) exercise by Eric Wastl. All solutions are written in [Swift](https://www.swift.org/about/) and packaged within [Swift Playgrounds](https://www.apple.com/au/swift/playgrounds/), allowing you to download it and see it in action.

# 2022

- [Day 1](#Day 1)
- [Day 2](#Day 2)
- [Day 3](#Day 3)
- [Day 4](#Day 4)
---

### Day 1

Input is processed to type `[[Int]]`.

**Part- 1**

```swift
let caloriesPerElf = input.map { $0.reduce(0, +) }
guard let highestCalorieCount = caloriesPerElf.max() else { fatalError("Verify algorithm") }
```

**Part- 2**

```swift
let caloriesPerElfSorted = caloriesPerElf.sorted(by: >)
let top3CalorieCount = caloriesPerElfSorted.prefix(3)
let top3CalorieCountAgg = top3CalorieCount.reduce(0, +)
```

### Day 2
Input is processed to type `[[String]]`.

**Models**

```swift
enum EncryptionLexer {
    static func components(for input: String) -> (String, String)? {
        let inputCompnents = input.components(separatedBy: " ")
        guard inputCompnents.count == 2,
              let firstComponent = inputCompnents.first,
              let secondComponent = inputCompnents.last else { return nil }
        return (firstComponent, secondComponent)
    }
}

enum EncryptionParser {
    case rhsIsPlayerHandShape
    case rhsIsRoundResult
    
    func generateRound(from lexme: (String, String)?) -> RockPaperScissorsRound? {
        guard let lexme = lexme else { return nil }
        
        func playerHandShapeFromLetter(_ letter: String) -> HandShape? {
            switch letter {
            case "X": return .rock
            case "Y": return .paper
            case "Z": return .scissors
            default: return nil
            }
        }
        
        func playerHandShapeFromResult(_ resultRaw: String, opponent: HandShape) -> HandShape? {
            guard let result = decodeResult(from: resultRaw) else { return nil }
            switch result {
            case .w: return opponent.losesAgainst
            case .d: return opponent
            case .l: return opponent.winsAgainst
            }
        }
        
        func decodeResult(from input: String) -> RockPaperScissorsRound.Result? {
            switch input {
            case "X": return .l
            case "Y": return .d
            case "Z": return .w
            default: return nil
            }
        }
        
        guard let opponent = HandShape(lexme.0) else { return nil }
        switch self {
        case .rhsIsPlayerHandShape:
            guard let player = playerHandShapeFromLetter(lexme.1) else { return nil }
            return RockPaperScissorsRound(opponent: opponent, player: player)
            
        case .rhsIsRoundResult:
            guard let player = playerHandShapeFromResult(lexme.1, opponent: opponent) else { return nil }
            return RockPaperScissorsRound(opponent: opponent, player: player)
        }
    }
}

enum HandShape: Int, Equatable {
    case rock = 1, paper, scissors
    
    init?(_ letter: String?) {
        switch letter {
        case "A": self = .rock
        case "B": self = .paper
        case "C": self = .scissors
        default: return nil
        }
    }
    
    var winsAgainst: HandShape {
        switch self {
        case .rock: return .scissors
        case .paper: return .rock
        case .scissors: return .paper
        }
    }
    
    var losesAgainst: HandShape { winsAgainst.winsAgainst }
}

struct RockPaperScissorsRound {
    let opponent: HandShape
    let player: HandShape
    
    enum Result: Int {
        case l = 0
        case d = 3
        case w = 6
    }
    
    func score() -> Int {
        let result = roundResult()
        return player.rawValue + result.rawValue
    }
    
    func roundResult() -> Result {
        switch (opponent, player) {
        case (.rock, .paper), (.paper, .scissors), (.scissors, .rock): return .w
        case _ where opponent == player: return .d
        default: return .l
        }
    }
    
    static func requiredHandShape(for result: Result, against opponent: HandShape) -> HandShape {
        switch result {
        case .w: return opponent.winsAgainst
        case .d: return opponent
        case .l: return opponent.losesAgainst
        }
    }
}
```

**Part- 1**

```swift
let rockPaperScissorsRoundsPart1 = input
    .map(EncryptionLexer.components)
    .compactMap(EncryptionParser.rhsIsPlayerHandShape.generateRound)

let finalScorePart1 = rockPaperScissorsRoundsPart1
    .map { $0.score() }
    .reduce(0, +)
```

**Part- 2**

```swift
let rockPaperScissorsRoundsPart2 = input
    .map(EncryptionLexer.components)
    .compactMap(EncryptionParser.rhsIsRoundResult.generateRound)

let finalScorePart2 = rockPaperScissorsRoundsPart2
    .map { $0.score() }
    .reduce(0, +)
```

### Day 3
Input is processed to type `[String]`.

**Helpers**
```swift
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

let inputElfPairs = input.map { $0.split(separator: ",") }
```

**Models**
```swift
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
```

**Part- 1**

```swift
let priorityAggregated = input
    .compactMap(RuckSack.init)
    .compactMap { $0.itemInBothCompartments() }
    .compactMap { $0.rucksackItemPriority }
    .reduce(0, +)
```

**Part- 2**
```swift
let groupPriorityAggregated = input
    .chunked(ElfGroup.groupSize)
    .compactMap(ElfGroup.init)
    .compactMap { $0.group.rucksackItemPriority }
    .reduce(0, +)
```

### Day 4
Input is processed to type `[String]`.

**Helpers**
```swift
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
```

**Models**
```swift
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
```

**Part-1**
```swift
let jobAssignmentPairs = inputElfPairs
    .map { $0.compactMap { sections in sections.asClosedRange } }
    .compactMap(JobAssignmentPair.init)

let assignmentsWithFullyOverlappingRanges = jobAssignmentPairs
    .filter { $0.completeOverlap }
```

**Part-2**
```swift
let assignmentsWithOverlappingRanges = jobAssignmentPairs
    .filter { $0.overlapExists }
```
