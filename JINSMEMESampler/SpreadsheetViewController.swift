//
//  SpreadsheetViewController.swift
//  JINSMEMESampler
//
//  Created by Yuhei Miyazato on 12/5/15.
//  Copyright © 2015 mitolab. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SpreadsheetViewModel {
    
    let disposeBag = DisposeBag()
    
    var dataAry = Variable<[String]>([])
    var interval = Variable<Double>(10)    // in sec
    var stopSequence = PublishSubject<Bool>()
    var response = Variable<String>("")
    var counter = 0
    
    func retrieveData() {
        
        stopSequence = PublishSubject<Bool>()
        
        MEMELibAccess.sharedInstance.rx_realtimeDataReceived
            .takeUntil(self.stopSequence)
            .subscribeNext { [unowned self] realtimeData in
            
            var aLine = ""
            aLine += NSDate().description
            aLine += ","
            aLine += realtimeData.fitError.description
            aLine += ","
            aLine += realtimeData.isWalking.description
            aLine += ","
            aLine += realtimeData.powerLeft.description
            aLine += ","
            aLine += realtimeData.eyeMoveUp.description
            aLine += ","
            aLine += realtimeData.eyeMoveDown.description
            aLine += ","
            aLine += realtimeData.eyeMoveLeft.description
            aLine += ","
            aLine += realtimeData.eyeMoveRight.description
            aLine += ","
            aLine += realtimeData.blinkSpeed.description
            aLine += ","
            aLine += realtimeData.blinkStrength.description
            aLine += ","
            aLine += realtimeData.roll.description
            aLine += ","
            aLine += realtimeData.pitch.description
            aLine += ","
            aLine += realtimeData.yaw.description
            aLine += ","
            aLine += realtimeData.accX.description
            aLine += ","
            aLine += realtimeData.accY.description
            aLine += ","
            aLine += realtimeData.accZ.description
            self.dataAry.value.append(aLine)
        }//.addDisposableTo(self.disposeBag)
        
        myInterval(self.interval.value)
            .takeUntil(self.stopSequence)
            .subscribeNext { [unowned self] elapsedMin in
                
                // this scope must not be main thread
                
                // make post string
                var postStr = ""
                for aLine in self.dataAry.value {
                    postStr += aLine
                    postStr += "\n"
                }
                
                if postStr.utf16.count <= 0 {
                    return
                }
                
                postStr = "csv=\(postStr[postStr.startIndex..<postStr.endIndex.advancedBy(-1)])"
                
                // POST to google spread sheet
                let url = NSURL(string: "https://script.google.com/macros/s/AKfycbwyHr5krVVZPpbnUMg3YOGD2f0CI9mAnjwcZEzg9X17C3DZhVVp/exec")
                let req = NSMutableURLRequest(URL: url!, cachePolicy: .ReloadIgnoringCacheData, timeoutInterval: 20)
                req.HTTPMethod = "POST"
                req.HTTPBody = postStr.dataUsingEncoding(NSUTF8StringEncoding)
                
                NSURLSession.sharedSession().rx_JSON(req)
                .takeUntil(self.stopSequence)
                .subscribeNext{ [unowned self] jsonDic in
                    let dataNum = jsonDic["dataNum"] as! NSNumber
                    if dataNum.integerValue > 0 {
                        self.dataAry.value.removeRange(0..<dataNum.integerValue)
                        print(jsonDic)
                        self.response.value += "\(self.counter.description)\n \(jsonDic.description) \n\n"
                        self.counter++
                    }
                }
                
        }
    }
    
    func myInterval(interval: NSTimeInterval) -> Observable<Int> {
        return create { observer in
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
            
            var next = 0
            
            dispatch_source_set_timer(timer, 0, UInt64(interval * Double(NSEC_PER_SEC)), 0)
            let cancel = AnonymousDisposable {
                dispatch_source_cancel(timer)
            }
            dispatch_source_set_event_handler(timer, {
                if cancel.disposed {
                    return
                }
                observer.on(.Next(next++))
            })
            dispatch_resume(timer)
            
            return cancel
        }
    }
}

class SpreadsheetViewController : UIViewController {

    var vm = SpreadsheetViewModel()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var intervalTextField: UITextField!
    @IBOutlet weak var startStopBtn: UIButton!
    @IBOutlet weak var responseTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Spreadsheet"
        
        self.bind()
    }
    
    func bind() {
        
        // View to model bindings
        
        self.intervalTextField.rx_text.subscribeNext { [unowned self] intervalStr in
            if intervalStr.utf16.count > 0 {
                self.vm.interval.value = atof(intervalStr)
            }
        }.addDisposableTo(self.disposeBag)
        
        self.intervalTextField.rx_controlEvents(.EditingDidEndOnExit).subscribeNext {
            self.intervalTextField.resignFirstResponder()
        }.addDisposableTo(self.disposeBag)
        
        self.startStopBtn.rx_tap.subscribeNext { [unowned self] in
            
            let currentState = self.startStopBtn.selected
            
            if currentState == true {
                self.startStopBtn.setTitle("start", forState: .Normal)
                self.vm.stopSequence.on(.Next(true))
            } else {
                self.startStopBtn.setTitle("stop", forState: .Normal)
                self.vm.retrieveData()
            }
            self.startStopBtn.selected = !currentState
            
        }.addDisposableTo(self.disposeBag)
        
        
        // Model to View bindings
        self.vm.interval
            .subscribeOn(MainScheduler.sharedInstance)
            .map { interval in
                return String(interval)
            }
            .bindTo(self.intervalTextField.rx_text)
            .addDisposableTo(self.disposeBag)

        self.vm.response
            .subscribeNext({ [unowned self] str in
                dispatch_async(dispatch_get_main_queue()) {
                    self.responseTextView.text = str
                }
            })
            .addDisposableTo(self.disposeBag)
    }
}
