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
    
    init(from json:JSON) throws
    {
        (self.timestamp, self.message, self.logger, self.thread, self.level) =
            try json.lint
        {
            (
                timestamp: try $0.remove("@timestamp", as: String.self),
                message: try $0.remove("message", as: String.self),
                logger: try $0.remove("logger_name", as: String.self),
                thread: try $0.remove("thread_name", as: String.self),
                level: try $0.remove("level", as: String.self)
            )
        }
    }
    
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
    let logs: [Log] = try! content
        .split(whereSeparator: \.isNewline)
        .filter{ !$0.isEmpty }
        .map {
            let decoder = try Grammar.parse($0.utf8, as: JSON.Rule<String.Index>.Root.self)
            return try! Log(from: decoder)
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
