//: [Previous](@previous)

import Foundation

import PlaygroundSupport
import _Concurrency

PlaygroundPage.current.needsIndefiniteExecution = true

let day = 6

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
    
    /// Constants
    let packetMarkerUniqueCharRequirement = 4
    let messageStartUniqueCharRequirement = 14
    
    /// Models
    class CharStreamProcessor {
        let input: String
        let uniqueCharToDetect: Int
        
        init(input: String, uniqueCharToDetect: Int) {
            self.input = input
            self.uniqueCharToDetect = uniqueCharToDetect
        }
        
        func process() -> (charactersProcessed: String.SubSequence, charBuffer: String.SubSequence) {
            var charactersProcessed = input.prefix(uniqueCharToDetect - 1)
            var charBuffer = charactersProcessed
            
            for character in input.dropFirst(uniqueCharToDetect - 1) {
                charactersProcessed.append(character)
                
                if !(charBuffer.count < uniqueCharToDetect) {
                    charBuffer.removeFirst()
                }
                charBuffer.append(character)
                
                let charBufferUniqueElements = Set(charBuffer)
                guard charBufferUniqueElements.count != uniqueCharToDetect else { break }
            }
            
            return (charactersProcessed, charBuffer)
        }
    }
    
    /// Part-1
    var charStreamProcessor = CharStreamProcessor(input: inputString, uniqueCharToDetect: packetMarkerUniqueCharRequirement)
    let (sopCharactersProcessed, _) = charStreamProcessor.process()
    
    print("Charactes needed to be processed 🏭 before first start-of-packet: \(sopCharactersProcessed.count)")
    
    /// Part-2
    charStreamProcessor = CharStreamProcessor(input: inputString, uniqueCharToDetect: messageStartUniqueCharRequirement)
    let (messageCharactersProcessed, _) = charStreamProcessor.process()
    
    print("Charactes needed to be processed 🏭 before start of message: \(messageCharactersProcessed.count)")
}
//: [Next](@next)
