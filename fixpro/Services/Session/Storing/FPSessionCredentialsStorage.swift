import Foundation

protocol FPSessionCredentialsStorage {
    func save(_ token: String, forKey key: String) throws
    func retrieve(forKey key: String) throws -> String?
    func remove(forKey key: String) throws
}
