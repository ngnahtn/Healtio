//
//  AsyncOperation.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//

import Foundation

class AsyncOperation: Operation {
    enum State: String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
    }

    var state: State = .ready {
        willSet {
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: state.rawValue)
        }

        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }

    override var isConcurrent: Bool {
        return true
    }

    override var isReady: Bool {
        return super.isReady && state == .ready
    }

    override var isExecuting: Bool {
        return state == .executing
    }

    override var isFinished: Bool {
        return state == .finished
    }

    override func cancel() {
        super.cancel()
        finish()
    }

    override func start() {
        guard !isCancelled else {
            finish()
            return
        }
        if !isExecuting {
            state = .executing
        }
        main()
    }

    func finish() {
        if isExecuting {
            state = .finished
        }
    }
}
