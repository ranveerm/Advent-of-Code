import Foundation

public enum InputManager { }

extension InputManager {
    public static func fetchInput(day: Int, year: Int = Constants.year) async throws -> Data {
        guard let data = InputLocalCacheManager.fetchInput(day: day, year: year) else {
            let data = try await retrieveInputFromAPI(day: day, year: year)
            try InputLocalCacheManager.storeInput(data, day: day, year: year)
            
            return data
        }
        return data
    }
}

extension InputManager {
    public enum Error: Swift.Error, LocalizedError {
        case invalidResponse
        case invalidHTTPResponseStatusCode(Int)
        
        public var localizedDescription: String {
            switch self {
            case .invalidResponse: return "Response is not of type HTTPURLResponse"
            case .invalidHTTPResponseStatusCode(let statusCode): return "HTTP response status code: \(statusCode)"
            }
        }
    }
}

extension InputManager {
    static private func retrieveInputFromAPI(day: Int, year: Int) async throws -> Data {
        let (data, response) = try await API.fetchInput(day: day, year: year)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw Error.invalidResponse }
        guard httpResponse.statusCode == 200 else { throw Error.invalidHTTPResponseStatusCode(httpResponse.statusCode) }
        
        return data
    }
}
