//
//  EyeBlink.swift
//  JINSMEMESampler
//
//  Created by Yuhei Miyazato on 12/3/15.
//  Copyright © 2015 mitolab. All rights reserved.
//

import Foundation
import UIKit

class EyeBlinkViewController: UIViewController {
    
    var rtmData :MEMERealTimeData?
    var eyeLid: CAShapeLayer?
    var lowerEyeLid: CAShapeLayer?
    var centerEye: CAShapeLayer?
    var centerEyeInside: CAShapeLayer?
    
    var isBlinking: Bool = false
    var blinkSpeed: CGFloat = 0
    var isMovingLeft :Bool = false
    var isMovingRight :Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleViewRect = CGRectMake(0, 0, self.view.frame.width*0.5, 64)
        let titleLabel = UILabel(frame: titleViewRect)
        titleLabel.text = "Eye Blink"
        titleLabel.font = UIFont(name: "NotoSansCJKjp-Bold", size: 14)
        titleLabel.textAlignment = .Center
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textColor = UIColor.blackColor()
        self.navigationItem.titleView = titleLabel
        
        MEMELibAccess.sharedInstance.changeDataMode(MEME_COM_REALTIME)
        
        // debug
        //NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "timerFired", userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove Observer
        MEMELibAccess.sharedInstance.removeObserver(self, forKeyPath: AppConsts.MEMELibAccess.realtimeDataKey)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add Observer
        MEMELibAccess.sharedInstance.addObserver(self, forKeyPath: AppConsts.MEMELibAccess.realtimeDataKey, options: .New, context: nil)
    }
    
    // MARK: - KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        switch keyPath! {
        case AppConsts.MEMELibAccess.realtimeDataKey:
            self.rtmData = (object as! MEMELibAccess).realtimeData
            if (self.rtmData != nil) {
                
                blinkSpeed = CGFloat(self.rtmData!.blinkSpeed)
                self.isBlinking = (blinkSpeed > 0) ? true : false
                
                // Comment out if eye moving left/right needed
                //                self.isMovingLeft = (self.rtmData!.eyeMoveLeft > 0) ? true : false
                //                self.isMovingRight = (self.rtmData!.eyeMoveRight > 0) ? true : false
                
                if self.isBlinking == true
                    //                   self.isMovingLeft || self.isMovingRight
                {
                    self.view.setNeedsLayout()
                }
            }
        default: break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //print("blinkSpeed \(self.rtmData?.blinkSpeed)")
        
        let origEyeLidSize = CGSizeMake(80, 36)
        let eyeLidWidth = self.view.frame.width - 20*2
        let eyeLidSize = CGSizeMake(
            eyeLidWidth,
            (eyeLidWidth * origEyeLidSize.height) / origEyeLidSize.width
        )
        let eyeLidRect = CGRectMake(
            20, (CGRectGetHeight(self.view.frame) - eyeLidSize.height)*0.5,
            eyeLidSize.width, eyeLidSize.height)
        
        // まばたき
        if self.isBlinking {
            
            AudioPlayer.sharedInstance.play("click")
            
            if self.eyeLid != nil {
                self.eyeLid?.removeFromSuperlayer()
            }
            self.eyeLid = CAShapeLayer.eyeBlinkWithFrame(eyeLidRect, blinkSpeed: (blinkSpeed/1000) * AppConsts.EyeBlink.blinkSpeedMulti)
            self.view.layer.addSublayer(self.eyeLid!)
        }
        
        // 下まぶた(常時表示)
        if self.lowerEyeLid == nil {
            self.lowerEyeLid = CAShapeLayer.lowerEyeWithFrame(eyeLidRect)
            self.view.layer.addSublayer(self.lowerEyeLid!)
        }
        
        // めんたま (デフォは中心にくるように)
        if self.centerEye != nil {
            self.centerEye?.removeFromSuperlayer()
            self.centerEyeInside?.removeFromSuperlayer()
        }
        
        //        // Comment out if needed eye move left/right
        //        if self.isMovingLeft {
        //            self.centerEye = CAShapeLayer.moveTo("left", withFrame: eyeLidRect, speed: 0.7, outside: true)
        //            self.centerEyeInside = CAShapeLayer.moveTo("left", withFrame: eyeLidRect, speed: 0.7, outside: false)
        //
        //        } else if self.isMovingRight {
        //            self.centerEye = CAShapeLayer.moveTo("right", withFrame: eyeLidRect, speed: 0.7, outside: true)
        //            self.centerEyeInside = CAShapeLayer.moveTo("right", withFrame: eyeLidRect, speed: 0.7, outside: false)
        //
        //        } else {
        self.centerEye = CAShapeLayer.centerEyeWithFrame(eyeLidRect, outside: true)
        self.centerEyeInside = CAShapeLayer.centerEyeWithFrame(eyeLidRect, outside: false)
        //        }
        
        //        let centerEyeInset:CGFloat = 36
        //        let centerEyeSize = CGSizeMake(
        //            eyeLidSize.height - centerEyeInset*2,
        //            eyeLidSize.height - centerEyeInset*2
        //        )
        //        let centerEyeRect = CGRectMake(
        //            CGRectGetMidX(self.view.frame) - centerEyeSize.width*0.5,
        //            CGRectGetMidY(eyeLidRect) - centerEyeSize.height*0.5,
        //            centerEyeSize.width, centerEyeSize.height)
        //
        //        self.centerEye = CAShapeLayer()
        //        self.centerEye?.fillColor = UIColor.blackColor().CGColor
        //        self.centerEye?.path = UIBezierPath(ovalInRect: centerEyeRect).CGPath
        //self.centerEyeInside?.zPosition = CGFloat(-Int.max + 1)
        self.centerEye?.zPosition = CGFloat(-Int.max)
        self.view.layer.addSublayer(self.centerEye!)
        self.view.layer.addSublayer(self.centerEyeInside!)
    }
    
    func timerFired() {
        // virtually blink
        self.isBlinking = !self.isBlinking
        self.isMovingLeft = !self.isMovingLeft
        self.view.setNeedsLayout()
    }
    
}
