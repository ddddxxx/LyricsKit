import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

let sharedURLSession = URLSession(configuration: .ephemeral)
