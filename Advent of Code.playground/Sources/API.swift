import Foundation

/*:
 - Notes:
    1. Cookie policy- all cookies that were added before present day are removed
 */
public enum API { }

extension API {
    static private let base = "https://adventofcode.com"
    static private let cookieSessionValue = ""
}

extension API {
    static public func fetchInput(day: Int, year: Int = Constants.year) async throws -> (Data, URLResponse) {
        var url = try constructURL(day: day, year: year)
        try configureCookies(for: url)
        
        url.append(path: "input")
        return try await URLSession.shared.data(from: url)
    }
}

// MARK: Nested Types
extension API {
    enum Error: Swift.Error {
        case unableToSetSessionCookie
        case unableToConstructURL
    }
}

// MARK: Helper Methods
extension API {
    static private func constructURL(day: Int, year: Int) throws -> URL {
        guard let url = URL(string: base)?.appending(path: "\(year)/day/\(day)") else { throw Error.unableToConstructURL }
        return url
    }
    
    static private func configureCookies(for url: URL) throws {
        let cookiePersistenceWindow = Date().addingTimeInterval(-4 * 24 * 60 * 60)
        /// Note-1
        HTTPCookieStorage.shared.removeCookies(since: cookiePersistenceWindow)
        
        /*:
         - [Swift - How to set cookie in NSMutableURLRequest](https://stackoverflow.com/questions/34590992/swift-how-to-set-cookie-in-nsmutableurlrequest)
         - []
         */
        guard let cookie = HTTPCookie.cookies(withResponseHeaderFields: ["Set-Cookie": "session=\(cookieSessionValue)"], for: url).first else {
            throw Error.unableToSetSessionCookie
        }
        
        HTTPCookieStorage.shared.setCookie(cookie)
    }
}
