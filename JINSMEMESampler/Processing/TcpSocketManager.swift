//
//  TcpSocketManager.swift
//  JINSMEMESampler
//
//  Created by Yuhei Miyazato on 12/6/15.
//  Copyright © 2015 mitolab. All rights reserved.
//

import Foundation
import RxSwift

public class TcpSocketManager: NSOperation, NSStreamDelegate {
    
    private var inputStream: NSInputStream!
    private var outputStream: NSOutputStream!
    
    private var excessElemStr: String?
    private var _executing = false
    private var runloop :NSRunLoop!
    
    public var streamSeq = PublishSubject<(NSStream, NSStreamEvent)>()
    
    // MARK: - Overrides
    public override func start() {
        
        NSThread.detachNewThreadSelector("main", toTarget: self, withObject: nil)
        _executing = true
    }
    
    public override func main() {
        
        autoreleasepool {
            
            self.runloop = NSRunLoop.currentRunLoop()
            
            self.inputStream.delegate = self
            self.inputStream.scheduleInRunLoop(self.runloop, forMode: NSDefaultRunLoopMode)
            self.inputStream.open()
            
            self.outputStream.delegate = self
            self.outputStream.scheduleInRunLoop(self.runloop, forMode: NSDefaultRunLoopMode)
            self.outputStream.open()
            
            repeat{
                autoreleasepool {
                    self.runloop.runUntilDate(NSDate(timeIntervalSinceNow:0.1))
                }
            } while (_executing)
        }
    }
    
    // MARK: - Custom Class Methods
    public func connect(newIp:String, port newPort:UInt32) {
        
        var readStream: Unmanaged<CFReadStreamRef>?
        var writeStream: Unmanaged<CFWriteStreamRef>?
        CFStreamCreatePairWithSocketToHost(nil, newIp, newPort, &readStream, &writeStream)
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        self.start()
    }
    
    public func disconnect() {
        
        if self._executing {
            self.inputStream.removeFromRunLoop(self.runloop, forMode: NSDefaultRunLoopMode)
            self.inputStream.close()
            self.outputStream.removeFromRunLoop(self.runloop, forMode: NSDefaultRunLoopMode)
            self.outputStream.close()
            
            self._executing = false
        }
    }
    
    public func sendData(dataStr:String) {
        
        if self.outputStream != nil && self.outputStream.hasSpaceAvailable {
            self.outputStream.write(dataStr, maxLength: dataStr.characters.count)
        }
    }
    
    // MARK: - NSStreamDelegate Method
    public func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        self.streamSeq.on(.Next((aStream, eventCode)))
    }
}
