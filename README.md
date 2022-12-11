# 🎄 Advent-of-Code 🎄
Responses to [Advent of Code](https://adventofcode.com/2022/about) exercise by Eric Wastl. All solutions are written in [Swift](https://www.swift.org/about/) and packaged within [Swift Playgrounds](https://www.apple.com/au/swift/playgrounds/), allowing you to download it and see it in action.

# 2022
### Day 1
Input is processed to type `[[Int]]`.

Part- 1
```swift
let caloriesPerElf = input.map { $0.reduce(0, +) }
guard let highestCalorieCount = caloriesPerElf.max() else { fatalError("Verify algorithm") }
```

Part- 2
```swift
let caloriesPerElfSorted = caloriesPerElf.sorted(by: >)
let top3CalorieCount = caloriesPerElfSorted.prefix(3)
let top3CalorieCountAgg = top3CalorieCount.reduce(0, +)
```

### Day 2
Input is processed to type `[[String]]`.

Models
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

Part- 1
```swift
let rockPaperScissorsRoundsPart1 = input
    .map(EncryptionLexer.components)
    .compactMap(EncryptionParser.rhsIsPlayerHandShape.generateRound)

let finalScorePart1 = rockPaperScissorsRoundsPart1
    .map { $0.score() }
    .reduce(0, +)
```

Part- 2
```swift
let rockPaperScissorsRoundsPart2 = input
    .map(EncryptionLexer.components)
    .compactMap(EncryptionParser.rhsIsRoundResult.generateRound)

let finalScorePart2 = rockPaperScissorsRoundsPart2
    .map { $0.score() }
    .reduce(0, +)
```