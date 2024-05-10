import Dependencies
import Foundation
import XCTestDynamicOverlay

public enum KeychainKeys: String {
    case uuid
}

public struct KeychainClient {
    public let setValue: (KeychainKeys, String?) -> Void
    public let getValue: (KeychainKeys) -> String?
}

extension KeychainClient: DependencyKey {
    public static var liveValue: KeychainClient = KeychainClient(
        setValue: { key, value in
            guard let value else {
                let query: NSDictionary = [
                    kSecClass: kSecClassGenericPassword,
                    kSecAttrAccount: key.rawValue
                ]
                SecItemDelete(query)
                return
            }
            let query: NSDictionary = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key.rawValue,
                kSecValueData: value.data(using: .utf8, allowLossyConversion: false) ?? .init()
            ]
            SecItemDelete(query)
            SecItemAdd(query, nil)
        },
        getValue: { key in
            let query: NSDictionary = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key.rawValue,
                kSecReturnData: kCFBooleanTrue!,
                kSecMatchLimit: kSecMatchLimitOne
            ]
            var dataTypeRef: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
            if status == errSecSuccess {
                guard let data = dataTypeRef as? Data else { return "" }
                return String(data: data, encoding: .utf8) ?? ""
            }
            return ""
        }
    )
}

extension KeychainClient: TestDependencyKey {
    public static var testValue: KeychainClient = KeychainClient(
        setValue: { _, _ in },
        getValue: { _ in "" }
    )
}

public extension DependencyValues {
    var keychainClient: KeychainClient {
        get { self[KeychainClient.self] }
        set { self[KeychainClient.self] = newValue }
    }
}
