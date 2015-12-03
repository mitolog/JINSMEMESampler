//
//  MEMELib+Rx.swift
//  JINSMEMESampler
//
//  Created by Yuhei Miyazato on 12/3/15.
//  Copyright © 2015 mitolab. All rights reserved.
//

import RxSwift
import Foundation

class MEMELibAccess: NSObject, MEMELibDelegate {
    
    static let sharedInstance = MEMELibAccess()
    
    var rx_realtimeDataReceived = PublishSubject<MEMERealTimeData>()
    var rx_memePeripheralFound = PublishSubject<CBPeripheral>()
    var rx_memeConnected = PublishSubject<CBPeripheral>()
    var rx_memeDisconnected = PublishSubject<CBPeripheral>()
    var rx_memeAppAuthorized = PublishSubject<MEMEStatus>()
    var rx_memeCommandResponse = PublishSubject<MEMEResponse>()
    
    override init() {
        super.init()
        MEMELib.sharedInstance().delegate = self
    }
    
    // MARK: - Wrapper for MEMELib instance methods (not all)
    class func scan() {
        MEMELibAccess.checkStatus(MEMELib.sharedInstance().startScanningPeripherals())
    }
    
    class func stopScan() {
        MEMELib.sharedInstance().stopScanningPeripherals()
    }

    class func connect(peripheral:CBPeripheral) {
        MEMELibAccess.checkStatus(MEMELib.sharedInstance().connectPeripheral(peripheral))
    }

    class func disconnect() {
        MEMELib.sharedInstance().disconnectPeripheral()
    }
    
    // MARK: - Wrapper for MEMELidDelegate
    // Methods below are publishing each event to multiple subscriber
    func memePeripheralFound(peripheral: CBPeripheral!, withDeviceAddress address: String!) {
        self.rx_memePeripheralFound.on(.Next(peripheral))
    }
    
    func memePeripheralConnected(peripheral: CBPeripheral!) {
        self.rx_memeConnected.on(.Next(peripheral))
    }
    
    func memePeripheralDisconnected(peripheral: CBPeripheral!) {
        self.rx_memeDisconnected.on(.Next(peripheral))
    }
    
    func memeRealTimeModeDataReceived(data: MEMERealTimeData!) {
        self.rx_realtimeDataReceived.on(.Next(data))
    }
    
    func memeAppAuthorized(status: MEMEStatus) {
        MEMELibAccess.checkStatus(status)
        self.rx_memeAppAuthorized.on(.Next(status))
    }
    
    func memeCommandResponse(response: MEMEResponse) {
        
        print(NSString(format: "Command Response - eventCode: 0x%02x - commandResult: %d", response.eventCode, response.commandResult.boolValue))
        
        switch response.eventCode {
            case 0x02:
                print("Data Report Started")
            case 0x04:
                print("Data Report Stopped")
            default:
                break
        }
        
        self.rx_memeCommandResponse.on(.Next(response))
    }
    
    // MARK: - Utility
    class func checkStatus(status:MEMEStatus) {
        
        switch status {
            case MEME_ERROR_APP_AUTH:
                print("\(__FUNCTION__): App Auth Failed. Invalid Application ID or Client Secret.")
            case MEME_ERROR_SDK_AUTH:
                print("\(__FUNCTION__): SDK Auth Failed. Invalid SDK. Please update to the latest SDK.")
            case MEME_CMD_INVALID:
                print("\(__FUNCTION__): SDK Error. Invalid Command.")
            case MEME_ERROR_BL_OFF:
                print("\(__FUNCTION__): Error. Bluetooth is off.")
            case MEME_OK:
                print("\(__FUNCTION__): OK.")
            default:
                print("\(__FUNCTION__): no scope has passed.")
        }
    }
}