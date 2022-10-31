//
//  OperationQueueManager.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//

import Foundation
class SKOperationQueue {
    private var maxConcurentCount = 1
    private var qualityOfService: QualityOfService = .default
    lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = qualityOfService
        queue.maxConcurrentOperationCount = maxConcurentCount
        return queue
    }()

    init(maxConcurentCount: Int = 1, qualityOfService: QualityOfService = .default) {
        self.maxConcurentCount = maxConcurentCount
        self.qualityOfService = qualityOfService
    }

    func addOperations(_ operations: [Operation], waitUntilFinish: Bool = false, completion: (() -> Void)? = nil) {
        queue.addOperations(operations, waitUntilFinished: waitUntilFinish)
        if let `completion` = completion {
            setCompletionBlock(completion)
        }
    }

    func setCompletionBlock(_ completion: @escaping () -> Void) {
        let blockOperation = BlockOperation(block: {
            DispatchQueue.main.async {
                completion()
            }
        })
        for operation in queue.operations {
            blockOperation.addDependency(operation)
        }
        queue.addOperation(blockOperation)
    }

    func cancelAllOperations() {
        queue.cancelAllOperations()
    }
}
