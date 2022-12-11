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
