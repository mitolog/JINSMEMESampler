//
//  ProcessingViewController.swift
//  JINSMEMESampler
//
//  Created by Yuhei Miyazato on 12/6/15.
//  Copyright © 2015 mitolab. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class ProcessingViewModel {
    
    let tcpManager = TcpSocketManager()

    let disposeBag = DisposeBag()
    var dataAry = Variable<[Dictionary<String,String>]>([Dictionary<String,String>]())
    var startStopBtnSequence = PublishSubject<Bool>()
    var tcpStreamStatusSequence = PublishSubject<Bool>()
    
    var hostIpSeq = PublishSubject<String>()
    var hostPortSeq = PublishSubject<String>()
    
    func getPreviousIpHost() {
        let sud = NSUserDefaults.standardUserDefaults()
        let storedHostIp = sud.objectForKey(Consts.Processing.hostIpKey) as! String?
        let storedHostPort = sud.objectForKey(Consts.Processing.hostPortKey) as! String?
        
        if let hostIp = storedHostIp {
            self.hostIpSeq.on(.Next(hostIp))
        }
        if let hostPort = storedHostPort {
            self.hostPortSeq.on(.Next(hostPort))
        }
    }
    
    func sendData() {
        
        var csvStr = ""
        for elemDic in self.dataAry.value {
            csvStr += elemDic.first!.1
            csvStr += ","
        }
        csvStr += "\n"
        
        self.tcpManager.sendData(csvStr)
    }
    
    func retrieveData() {
        
        _ =
        MEMELibAccess.sharedInstance.rx_realtimeDataReceived
            .subscribeNext { [unowned self] realtimeData in
        
            var dataDic = [Dictionary<String,String>]()
            dataDic.append(["fitError" : realtimeData.fitError.description])
            dataDic.append(["isWalking":realtimeData.isWalking.description])
            dataDic.append(["powerLeft":realtimeData.powerLeft.description])
            dataDic.append(["eyeMoveUp":realtimeData.eyeMoveUp.description])
            dataDic.append(["eyeMoveDown":realtimeData.eyeMoveDown.description])
            dataDic.append(["eyeMoveLeft":realtimeData.eyeMoveLeft.description])
            dataDic.append(["eyeMoveRight":realtimeData.eyeMoveRight.description])
            dataDic.append(["blinkSpeed":realtimeData.blinkSpeed.description])
            dataDic.append(["blinkStrength":realtimeData.blinkStrength.description])
            dataDic.append(["roll":realtimeData.roll.description])
            dataDic.append(["pitch":realtimeData.pitch.description])
            dataDic.append(["yaw":realtimeData.yaw.description])
            dataDic.append(["accX":realtimeData.accX.description])
            dataDic.append(["accY":realtimeData.accY.description])
            dataDic.append(["accZ":realtimeData.accZ.description])
            
            self.dataAry.value = dataDic
    
        }.addDisposableTo(self.disposeBag)
    }
    
    func bindViews(controller:ProcessingViewController) {
        
        /* Bind Model to View */
        self.hostIpSeq
            .subscribeOn(MainScheduler.sharedInstance)
            .filter({ hostIp in
                return hostIp.characters.count > 0
            })
            .bindTo(controller.hostIpTextField.rx_text)
            .addDisposableTo(self.disposeBag)
        
        self.hostPortSeq
            .subscribeOn(MainScheduler.sharedInstance)
            .filter({ hostPort in
                return hostPort.characters.count > 0
            })
            .bindTo(controller.hostPortTextField.rx_text)
            .addDisposableTo(self.disposeBag)
        
        combineLatest(self.hostIpSeq, self.hostPortSeq) { (hostIp, hostPort) in
                return hostIp.characters.count > 0 && hostPort.characters.count > 0
            }
            .bindTo(controller.startStopBtn.rx_enabled)
            .addDisposableTo(self.disposeBag)
        
        self.dataAry.bindTo(controller.tableView.rx_itemsWithCellIdentifier("ProcessingDataViewCell")) { _, dic, cell in
                cell.textLabel?.text = dic.keys.first!
                cell.detailTextLabel?.text = dic.values.first!
            }.addDisposableTo(self.disposeBag)
        
        self.startStopBtnSequence
            .subscribeOn(MainScheduler.sharedInstance)
            .subscribeNext { [unowned self, controller] currentState in
                
                if currentState == true {
                    self.disconnect()
                    controller.startStopBtn.setTitle("start", forState: .Normal)
                } else {
                    
                    let ipStr = controller.hostIpTextField.text!
                    let portStr = controller.hostPortTextField.text!
                    
                    self.connect(ipStr, portStr)
                    
                    // Save current IP/Port
                    let sud = NSUserDefaults.standardUserDefaults()
                    sud.setValue(ipStr, forKey: Consts.Processing.hostIpKey)
                    sud.setValue(portStr, forKey: Consts.Processing.hostPortKey)
                    sud.synchronize()
                    
                    controller.startStopBtn.setTitle("stop", forState: .Normal)
                }
                controller.startStopBtn.selected = !currentState
                
            }.addDisposableTo(self.disposeBag)
        
        combineLatest(self.startStopBtnSequence, self.tcpStreamStatusSequence, self.dataAry) { btnState, streamOpened, dataAry in
                return !btnState && streamOpened && dataAry.count > 0   // when btnState is false, it is a selected state
            }
            .filter({ canSend in
                return canSend
            })
            .subscribeNext { [unowned self] canSend in
                self.sendData()
            }.addDisposableTo(self.disposeBag)
        
        /* Bind View to Model */
        // Host IP
        controller.hostIpTextField.rx_text
            .filter{ [unowned self] hostIp in
                
                if (hostIp.characters.count > 0
                    && hostIp.componentsSeparatedByString(".").count == 4
                    && hostIp.componentsSeparatedByString(".").last!.characters.count > 0 )
                {
                    return true
                } else {
                    self.hostIpSeq.on(.Next(""))
                    return false
                }
            }.subscribeNext { [unowned self] hostIp in
                self.hostIpSeq.on(.Next(hostIp))
            }.addDisposableTo(self.disposeBag)
        
        controller.hostIpTextField.rx_controlEvents(.EditingDidEndOnExit)
            .subscribeNext { [unowned controller] in
                controller.hostIpTextField.resignFirstResponder()
            }.addDisposableTo(self.disposeBag)
        
        // Host Port
        controller.hostPortTextField.rx_text
            .filter{ [unowned self] hostPort in
                if (hostPort.characters.count >= 5
                    && Int(hostPort) >= 49152
                    && Int(hostPort) <= 65535)
                {
                    return true
                } else {
                    self.hostPortSeq.on(.Next(""))
                    return false
                }
            }.subscribeNext { [unowned self] hostPort in
                self.hostPortSeq.on(.Next(hostPort))
            }.addDisposableTo(self.disposeBag)
        
        controller.hostPortTextField.rx_controlEvents(.EditingDidEndOnExit)
            .subscribeNext { [unowned controller] in
                controller.hostPortTextField.resignFirstResponder()
            }.addDisposableTo(self.disposeBag)
        
        // startstop button
        controller.startStopBtn.rx_tap
            .map{ [unowned controller] in
                (controller.startStopBtn.selected) ?? false
            }
            .bindTo(self.startStopBtnSequence)
            .addDisposableTo(self.disposeBag)

    }
    
    func bindToSocket(presentingController:ProcessingViewController) {
        
        _ =
        self.tcpManager.streamSeq
            .subscribeOn(MainScheduler.sharedInstance)
            .subscribeNext{ [unowned self] (aStream, eventCode) in
                
                switch eventCode {
                case NSStreamEvent.HasBytesAvailable:
                    // todo: deal with response
                    print("read something")
                //case NSStreamEvent.HasSpaceAvailable:
                    // It is called when you asks stream.hasSpaceAvailable
                case NSStreamEvent.ErrorOccurred:
                    print("some error occured connecting socket")
                    
                    dispatch_async(dispatch_get_main_queue(), { [unowned presentingController] in
                        let alert = UIAlertController(title: "TCP Socket error", message: "some error occured while connecting TCP socket. Program disconnected socket, please retry.", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        presentingController.presentViewController(alert, animated: true, completion: nil)
                    })

                    self.startStopBtnSequence.on(.Next(true))   // imitate button press
                    
                case NSStreamEvent.OpenCompleted:
                    print("socket open completed")
                    self.tcpStreamStatusSequence.on(.Next(true))
                default:
                    print("unexpected eventCode has come while streaming")
                }
            }
            .addDisposableTo(self.disposeBag)
    }
    
    func connect(hostIp:String, _ hostPort:String) {
        self.tcpManager.connect(hostIp, port: UInt32(hostPort)!)
    }
    
    func disconnect() {
        self.tcpManager.disconnect()
    }
}

class ProcessingViewController : UIViewController {
    
    @IBOutlet weak var hostIpTextField: UITextField!
    @IBOutlet weak var hostPortTextField: UITextField!
    @IBOutlet weak var startStopBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let vm = ProcessingViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Processing"

        self.vm.bindViews(self)
        
        self.vm.retrieveData()  // keep reading MEME data until deallocated
        self.vm.getPreviousIpHost()
        self.vm.bindToSocket(self)
    }
}
