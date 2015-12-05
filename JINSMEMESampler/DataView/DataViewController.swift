//
//  DataViewController.swift
//  JINSMEMESampler
//
//  Created by Yuhei Miyazato on 12/4/15.
//  Copyright © 2015 mitolab. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DataViewModel {
    
    var dataAry = Variable<[Dictionary<String,String>]>([Dictionary<String,String>]())
}

class DataViewController: UITableViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = DataViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "DataView"
        
        MEMELibAccess.sharedInstance.rx_realtimeDataReceived.subscribeNext { [unowned self] realtimeData in
            
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
            
            self.viewModel.dataAry.value = dataDic

        }.addDisposableTo(self.disposeBag)
        
        self.viewModel.dataAry.bindTo(self.tableView.rx_itemsWithCellIdentifier("DataViewCell")) { _, dic, cell in
            cell.textLabel?.text = dic.keys.first!
            cell.detailTextLabel?.text = dic.values.first!
        }.addDisposableTo(self.disposeBag)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}