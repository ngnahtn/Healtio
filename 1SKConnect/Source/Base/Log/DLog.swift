//
//  DLog.swift
//  Project
//
//  Created by Be More on 24/03/2021.
//

import Foundation

enum DLogTag: String {
    case debug = "💜[DEBUG]"
    case info = "💚[INFO]"
    case warning = "💛[WARNING]"
    case error = "❤️[ERROR]"
}

/// Print debug information
///
/// - Parameters:
///   - tag: Log type
///   - logMessage: Log content
///   - functionName: funcntion call log
///   - line: The line in which the log was written
///   - fileName: The file that own the log
///   - column: The beginning character of the log statement
/// - Returns: Void
private func dLog(_ tag: DLogTag, _ logMessage: Any, functionName: String = #function, line: Int = #line, fileName: String = #file, column: Int = #column) {
    #if RELEASE
    #else
    let tag = tag.rawValue
    let fileName = (fileName as NSString).lastPathComponent
    let logDate = Date().stringForLog()
    let logString = "\(logDate) \(tag) \(logMessage)\n\tAt: [\(fileName)] - [\(functionName)] - [Line \(line)]"
    Swift.print(logString)
    #endif
}

func dLogDebug(_ logMessage: Any, functionName: String = #function, line: Int = #line, fileName: String = #file, column: Int = #column) {
    dLog(.debug, logMessage, functionName: functionName, line: line, fileName: fileName, column: column)
}

func dLogInfo(_ logMessage: Any, functionName: String = #function, line: Int = #line, fileName: String = #file, column: Int = #column) {
    dLog(.info, logMessage, functionName: functionName, line: line, fileName: fileName, column: column)
}

func dLogWarning(_ logMessage: Any, functionName: String = #function, line: Int = #line, fileName: String = #file, column: Int = #column) {
    dLog(.warning, logMessage, functionName: functionName, line: line, fileName: fileName, column: column)
}

func dLogError(_ logMessage: Any, functionName: String = #function, line: Int = #line, fileName: String = #file, column: Int = #column) {
    dLog(.error, logMessage, functionName: functionName, line: line, fileName: fileName, column: column)
}
