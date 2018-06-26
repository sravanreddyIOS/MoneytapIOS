/*******************************************************************
 * © Copyright 2017. All Rights Reserved
 * Softtrends Software Private Limited.
 * Bangalore - 560038
 * India.
 *
 *
 * Project Name : nHance
 * File Name    : Backgroundable.swift
 * Group        : iOS
 * Security     : Confidential
 *
 *
 * Created by Pradeep BM on 27/02/17
 * Last Modified by Pradeep BM on 11/06/17.
 ********************************************************************/

import UIKit

//MARK: - Functions
//MARK: Background Task IDs
public struct BackgroundTask {
    @nonobjc private static var id = UIBackgroundTaskInvalid
    
    public static var active: Bool  = false {
        didSet {
            if oldValue != active {
                if active {
                    self.startBackgroundTask()
                } else {
                    self.endBackgroundTask()
                }
            }
        }
    }
    
    private static func startBackgroundTask() {
        self.endBackgroundTask()
        self.id = UIApplication.shared.beginBackgroundTask { () -> Void in
            if self.active {
                self.startBackgroundTask()
            }
        }
    }
    
    private static func endBackgroundTask() {
        if self.id == UIBackgroundTaskInvalid {
            return
        }
        UIApplication.shared.endBackgroundTask(self.id)
        self.id = UIBackgroundTaskInvalid
    }
}

public func startBackgroundTask() {
    BackgroundTask.active = true
}

public func endBackgroundTask() {
    BackgroundTask.active = false
}

//MARK: Dispatching
public struct Background {
    public static var cleanAfterDone = false {
        didSet {
            if cleanAfterDone {
                if Background.operationCount == 0 {
                    Background.concurrentQueue = nil
                }
            }
        }
    }
    
    private static var concurrentQueue: OperationQueue!
    private static var operationCount = 0
    
    public static func enqueue(operations: [Operation])
    {
        if operations.isEmpty {
            return
        }
        
        if Background.concurrentQueue == nil {
            let queue = OperationQueue()
            queue.name = "BackgroundableQueue"
            Background.concurrentQueue = queue
        }
        Background.operationCount += 1
        
        startBackgroundTask()
        
        for (index, item) in operations.enumerated() {
            if index + 1 < operations.count {
                item.addDependency(operations[index + 1])
            }
        }
        
        let last = operations.last!
        let completionBlock = last.completionBlock
        last.completionBlock = { () -> Void in
            if let block = completionBlock {
                onTheMainThread(x: block)
            }
            
            if Background.concurrentQueue != nil {
                Background.operationCount -= 1
                if Background.operationCount < 0 {
                    Background.operationCount = 0
                }
                if Background.operationCount == 0 && Background.cleanAfterDone {
                    Background.concurrentQueue = nil
                }
            }
            
            endBackgroundTask()
        }
        
        Background.concurrentQueue.addOperations(operations, waitUntilFinished: false)
    }
}

public func inTheBackground(x: @escaping () -> Void)
{
    Background.enqueue(operations: [BlockOperation(block: x)])
}

public func onTheMainThread(x: @escaping () -> Void)
{
    DispatchQueue.main.async {
        x()
    }
}
