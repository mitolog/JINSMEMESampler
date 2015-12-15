//
//  AutoLockScreenViewController.swift
//  JINSMEMESampler
//
//  Created by Yuhei Miyazato on 12/14/15.
//  Copyright © 2015 mitolab. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SocketIO

class AutoLockScreenViewModel {
    
    var socket:SocketIOClient?
    
    let disposeBag = DisposeBag()
    var dataAry = Variable<[Dictionary<String,String>]>([Dictionary<String,String>]())
    var startStopBtnSequence = PublishSubject<Bool>()
    var sioStreamStatusSequence = PublishSubject<Bool>()
    var sioStreamSequence = PublishSubject<String>()
    
    var hostUrlSeq = PublishSubject<String>()
    
    func getPreviousHostUrl() {
        let sud = NSUserDefaults.standardUserDefaults()
        let storedHostUrl = sud.objectForKey(Consts.AutoLockScreen.hostUrlKey) as! String?
        
        if let hostUrl = storedHostUrl {
            self.hostUrlSeq.on(.Next(hostUrl))
        }
    }
    
    func sendData() {
        
        var csvStr = ""
        for elemDic in self.dataAry.value {
            csvStr += elemDic.first!.1
            csvStr += ","
        }
        csvStr += "\n"
        
        self.socket?.emit("publish", csvStr)
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
    
    func bindViews(controller:AutoLockScreenViewController) {
        
        /* Bind Model -> View */
        self.hostUrlSeq
            .subscribeOn(MainScheduler.sharedInstance)
            .filter({ hostUrl in
                return hostUrl.characters.count > 0
            })
            .bindTo(controller.hostUrlTextField.rx_text)
            .addDisposableTo(self.disposeBag)
        
        self.dataAry.bindTo(controller.tableView.rx_itemsWithCellIdentifier("AutoLockScreenCell")) { _, dic, cell in
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
                    
                    let hostUrl = controller.hostUrlTextField.text!
                    
                    self.setupAndStartSocketIO(hostUrl, controller)
                    
                    // Save current IP/Port
                    let sud = NSUserDefaults.standardUserDefaults()
                    sud.setValue(hostUrl, forKey: Consts.AutoLockScreen.hostUrlKey)
                    sud.synchronize()
                    
                    controller.startStopBtn.setTitle("stop", forState: .Normal)
                }
                controller.startStopBtn.selected = !currentState
                
            }.addDisposableTo(self.disposeBag)
        
        combineLatest(self.startStopBtnSequence, self.sioStreamStatusSequence, self.dataAry) { btnState, streamOpened, dataAry in
            return !btnState && streamOpened && dataAry.count > 0   // when btnState is false, it is a selected state
            }
            .filter({ canSend in
                return canSend
            })
            .subscribeNext { [unowned self] canSend in
                if self.socket != nil {
                    self.sendData()
                }
            }.addDisposableTo(self.disposeBag)
        
        /* Bind View -> Model */
        // Host IP
        controller.hostUrlTextField.rx_text
            .filter{ [unowned self] hostUrl in
                
                if (hostUrl.characters.count > 0
                    && hostUrl.componentsSeparatedByString(":").count == 2
                    && hostUrl.componentsSeparatedByString(":").first!.characters.count > 0
                    && hostUrl.componentsSeparatedByString(":").last!.characters.count > 0 )
                {
                    return true
                } else {
                    self.hostUrlSeq.on(.Next(""))
                    return false
                }
            }.subscribeNext { [unowned self] hostUrl in
                self.hostUrlSeq.on(.Next(hostUrl))
            }.addDisposableTo(self.disposeBag)
        
        controller.hostUrlTextField.rx_controlEvents(.EditingDidEndOnExit)
            .subscribeNext { [unowned controller] in
                controller.hostUrlTextField.resignFirstResponder()
            }.addDisposableTo(self.disposeBag)
        
        // startstop button
        controller.startStopBtn.rx_tap
            .map{ [unowned controller] in
                (controller.startStopBtn.selected) ?? false
            }
            .bindTo(self.startStopBtnSequence)
            .addDisposableTo(self.disposeBag)
        
    }
    
    func showAlertAndImmitateToggleButton(msg:String, content:String, viewController:AutoLockScreenViewController) {
        dispatch_async(dispatch_get_main_queue(), {
            
            let alert = UIAlertController(title: msg, message: content, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            viewController.presentViewController(alert, animated: true, completion: nil)
        })
        self.startStopBtnSequence.on(.Next(true))   // imitate button press
    }
    
    func setupAndStartSocketIO(hostUrl:String, _ presentingController:AutoLockScreenViewController) {
        
        self.socket = SocketIOClient(socketURL: hostUrl)
        
        self.socket?.on("connect") { [unowned self] data, ack in
            self.sioStreamStatusSequence.on(.Next(true))
            self.socket?.emit("connected", Consts.AutoLockScreen.appName)
        }
        
        self.socket?.on("error", callback: { [unowned self, unowned presentingController] data, ack in
            
            self.showAlertAndImmitateToggleButton("SocketIO Error", content: "Program automatically disconnect socket, please retry. Error description: \(data.first!)", viewController: presentingController)
        })
        
        self.socket?.on("disconnect", callback: { [unowned self, unowned presentingController] data, ack in
            
            self.showAlertAndImmitateToggleButton("SocketIO Disconnectd", content: "I'm disconnected from socket.io server.", viewController: presentingController)
        })
        
        self.socket?.connect()
    }
    
    func disconnect() {
        self.socket?.disconnect()
        self.socket = nil
    }
}

class AutoLockScreenViewController: UIViewController {

    @IBOutlet weak var hostUrlTextField: UITextField!
    @IBOutlet weak var startStopBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let vm = AutoLockScreenViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Auto Lock Screen"
        
        self.vm.bindViews(self)

        self.vm.retrieveData()
        self.vm.getPreviousHostUrl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
