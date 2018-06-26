/*******************************************************************
 * Copyright (c) 2014 Le Van Nghia. All rights reserved.
 * Softtrends Software Private Limited.
 * Bangalore - 560038
 * India.
 *
 *
 * Project Name : nHance
 * File Name    : GCD.swift
 * Group        : iOS
 * Security     : Confidential
 *
 *
 * Created by Le Van Nghia on 7/25/14.
 * Last Modified by Pradeep BM on 11/06/17.
 ********************************************************************/

import Foundation

typealias GCDClosure = () -> Void
typealias GCDApplyClosure = (Int) -> ()

enum QueueType {
    case main
    case `default`
    case background
    case custom(GCDQueue)
    
    func getQueue() -> DispatchQueue {
        switch self {
        
        case .default:
            return DispatchQueue.global(qos: .default)
            
        case .background:
            return DispatchQueue.global(qos: .background)
            
            // return custom queue
        case .custom(let gcdQueue):
            return gcdQueue.dispatchQueue
            
            // return the serial dispatch queue associated with the application’s main thread
        case .main:
            fallthrough
            
        default:
            return DispatchQueue.main
        }
    }
}

class GCDQueue
{
    let dispatchQueue: DispatchQueue
    
    /**
    *  Init with main queue (tasks execute serially on your application’s main thread)
    */
    init() {
        dispatchQueue = DispatchQueue.main
    }
    
    /**
    *  Init with a serial queue (tasks execute one at a time in FIFO order)
    *
    *  @param label (can be nil)
    */
    init(serial label: String) {
        dispatchQueue = DispatchQueue(label: label, attributes: [])
    }
    
    /**
    *  Init with concurrent queue (tasks are dequeued in FIFO order, but run concurrently and can finish in any order)
    *
    *  @param label (can be nil)
    */
    init(concurrent label: String) {
        dispatchQueue = DispatchQueue(label: label, attributes: DispatchQueue.Attributes.concurrent)
    }
    
    /**
    *  Submits a barrier block for asynchronous execution and returns immediately
    *
    *  @param GCDClosure
    *
    */
    func asyncBarrier(_ closure: @escaping GCDClosure) {
        dispatchQueue.async(flags: .barrier, execute: closure)
    }
    
    /**
    *  Submits a barrier block object for execution and waits until that block completes
    *
    *  @param GCDClosure
    *
    */
    func syncBarrier(_ closure: GCDClosure) {
        dispatchQueue.sync(flags: .barrier, execute: closure)
    }
    
    /**
     *  Submits a block object for execution and waits until that block completes
     *
     *  @param GCDClosure
     *
     */
    func sync(_ closure: GCDClosure) {
        dispatchQueue.sync(execute: closure)
    }
    
    /**
    *  suspend queue
    *
    */
    func suspend() {
        dispatchQueue.suspend()
    }
    
    /**
    *  resume queue
    *
    */
    func resume() {
        dispatchQueue.resume()
    }
    
}

class GCDGroup
{
    let dispatchGroup: DispatchGroup
    
    init() {
        dispatchGroup = DispatchGroup()
    }
    
    func enter() {
        dispatchGroup.enter()
    }
    
    func leave() {
        dispatchGroup.leave()
    }
    
    /**
    *  Waits synchronously for the previously submitted block objects to complete
    *  returns if the blocks do not complete before the specified timeout period has elapsed
    *
    *  @param Double timeout in second
    *
    *  @return all blocks associated with the group completed before the specified timeout or not
    */
    func wait(_ timeout: Double) -> Bool {
        let t = timeout * Double(NSEC_PER_SEC)
        return dispatchGroup.wait(timeout: DispatchTime.now() + Double(Int64(t)) / Double(NSEC_PER_SEC)) == .success
    }
    
    /**
    *  Submits a block to a dispatch queue and associates the block with current dispatch group
    *
    *  @param QueueType
    *  @param GCDClosure
    *
    */
    func async(_ queueType: QueueType, closure: @escaping GCDClosure) {
        //queueType.getQueue().async(group: dispatchGroup, execute: closure)
        queueType.getQueue().async(group: dispatchGroup, execute: {
            closure()
        })
    }
    
    /**
    *  Schedules a block object to be submitted to a queue when
    *  previously submitted block objects of current group have completed
    *
    *  @param QueueType
    *  @param GCDClosure
    *
    */
    func notify(_ queueType: QueueType, closure: @escaping GCDClosure) {
        dispatchGroup.notify(queue: queueType.getQueue(), execute: closure)
    }
}

class GCD
{
    /**
    *  Async
    *  Submits a block for asynchronous execution on a dispatch queue and returns immediately
    *
    *  @param QueueType  : the queue (main or serially or concurrently) on which to submit the block
    *  @param GCDClosure : the block will be run
    *
    */
    class func async(_ queueType: QueueType, closure: @escaping GCDClosure) {
        queueType.getQueue().async(execute: closure)
    }
    
    // Enqueue a block for execution at the specified time
    class func async(_ queueType: QueueType, delay: Double, closure: @escaping GCDClosure) {
        let t = delay * Double(NSEC_PER_SEC)
        queueType.getQueue().asyncAfter(deadline: DispatchTime.now() + Double(Int64(t)) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    /**
    *  Sync
    *  Submits a block object for execution on a dispatch queue and waits until that block completes
    *
    *  @param QueueType  :  the queue (main or serially or concurrently) on which to submit the block
    *  @param GCDClosure :  the block will be run
    *
    */
    class func sync(_ queueType: QueueType, closure: GCDClosure) {
        queueType.getQueue().sync(execute: closure)
    }
    
    /**
    *  dispatch apply
    *  this method waits for all iterations of the task block to complete before returning
    *
    *  @param QueueType       :  the queue (main or serially or concurrently) on which to submit the block
    *  @param UInt            :  the number of iterations to perform
    *  @param GCDApplyClosure :  the block will be run
    *
    */
    class func apply(_ queueType: QueueType, interators: UInt, closure: GCDApplyClosure) {
        DispatchQueue.concurrentPerform(iterations: Int(interators), execute: closure)
    }
    
}
