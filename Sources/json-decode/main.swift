//
//  main.swift
//  JSONDecode
//
//  Created by Richard Jones on 27/07/2022.
//

import Foundation
import JSON

struct Log: Identifiable, Decodable {
    let timestamp: String
    let level: String
    let thread: String
    let logger: String
    let message: String
    let id = UUID()
    
    private enum CodingKeys : String, CodingKey {
        case timestamp = "@timestamp"
        case level
        case thread = "thread_name"
        case logger = "logger_name"
        case message
    }
}

private func foundation(file: URL) -> [Log] {
    let content: String = try! String(contentsOf: file, encoding: .utf8)
    let decoder: JSONDecoder = JSONDecoder()
    
    let startTime = CFAbsoluteTimeGetCurrent()
    let logs = content
        .split(whereSeparator: \.isNewline)
        .map { $0.trimmingCharacters(in: .whitespaces).data(using: .utf8) ?? Data() }
        .filter{ !$0.isEmpty }
        .map { try! decoder.decode(Log.self, from: $0) }
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("foundation time elapsed: \(timeElapsed) s.")
    return logs
}

private func swiftJson(file: URL) -> [Log] {
    let content: String = try! String(contentsOf: file, encoding: .utf8)
    
    let startTime = CFAbsoluteTimeGetCurrent()
    let logs: [Log] = content
        .split(whereSeparator: \.isNewline)
        .filter{ !$0.isEmpty }
        .map {
            let decoder: JSON = try! Grammar.parse($0.utf8, as: JSON.Rule<String.Index>.Root.self)
            return try! .init(from: decoder)
        }
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("swiftJson time elapsed: \(timeElapsed) s.")
    return logs
}

let arguments = CommandLine.arguments
let fileUrl = URL(fileURLWithPath: arguments[1])
print("fileUrl: \(fileUrl)")
print("Starting foundation read")
foundation(file: fileUrl)
print("Starting swift-json read")
swiftJson(file: fileUrl)
