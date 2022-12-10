import Foundation
import PlaygroundSupport

public enum InputLocalCacheManager { }

extension InputLocalCacheManager {
    private static let fileManager = FileManager.default
}

extension InputLocalCacheManager {
    static public let inputsBaseDir = playgroundSharedDataDirectory.appendingPathComponent("Advent of Code/Inputs")
}

extension InputLocalCacheManager {
    public static func fetchInput(day: Int, year: Int = Constants.year) -> Data? {
        guard contentExits(day: day, year: year) else { return nil }
        
        let fileURL = inputFileURL(day: day, year: year)
        return fileManager.contents(atPath: fileURL.path)
    }
    
    public static func storeInput(_ data: Data, day: Int, year: Int) throws {
        if !contentExits(day: nil, year: year) {
            let dirURL = inputsBaseDir.appendingPathComponent("\(year)")
            try fileManager.createDirectory(at: dirURL, withIntermediateDirectories: false)
        }
        
        let fileURL = inputFileURL(day: day, year: year)
        try data.write(to: fileURL)
    }
}

extension InputLocalCacheManager {
    /// If day is `nil`, then this method checks if the directory for year exists
    private static func contentExits(day: Int?, year: Int) -> Bool {
        var url = inputDir(year: year)
        if let day = day { url = url.appendingPathComponent(inputFileName(day: day, year: year)) }
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    private static func inputFileURL(day: Int, year: Int) -> URL { inputDir(year:year).appendingPathComponent(inputFileName(day: day, year: year))  }
    private static func inputDir(year: Int) -> URL { inputsBaseDir.appendingPathComponent("\(year)") }
    private static func inputFileName(day: Int, year: Int) -> String { "\(year)-\(day)" }
}
