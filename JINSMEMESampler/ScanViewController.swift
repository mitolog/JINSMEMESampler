//
//  ScanViewController.swift
//  JINSMEMESampler
//
//  Created by Yuhei Miyazato on 12/3/15.
//  Copyright © 2015 mitolab. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ScanViewModel {
    var peripherals = Variable<[CBPeripheral]>([])
}

class ScanViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanBtn: UIButton!
    let disposeBag = DisposeBag()
    let viewModel = ScanViewModel()
    
    func bindViewAndModel() {

        /***** UITableView related *****/

        // cellForRow~
        viewModel.peripherals.bindTo(self.tableView.rx_itemsWithCellIdentifier("PeripheralCell")) { _, peripheral, cell -> Void in
            cell.textLabel?.text = peripheral.identifier.UUIDString
        }.addDisposableTo(self.disposeBag)
        
        // tableview did selected
        self.tableView.rx_itemSelected.subscribeNext { [unowned self] indexPath in
            let peripheral = self.viewModel.peripherals.value[indexPath.row]
            MEMELibAccess.connect(peripheral)
        }.addDisposableTo(self.disposeBag)
        
        /***** MEMEDelegate related *****/
        
        MEMELibAccess.sharedInstance.rx_memePeripheralFound.subscribeNext { [unowned self] peripheral in
            
            var hasAlready = false
            for p in self.viewModel.peripherals.value {
                if p.identifier == peripheral.identifier {
                    hasAlready = true
                    break
                }
            }
            
            if !hasAlready {
                print("New peripheral found: \(peripheral.identifier)")
                self.viewModel.peripherals.value.append(peripheral)
            }
            
        }.addDisposableTo(self.disposeBag)

        MEMELibAccess.sharedInstance.rx_memeConnected.subscribeNext { [unowned self] peripheral in
            print("meme connected")
            self.scanBtn.enabled = false
            self.tableView.userInteractionEnabled = false
            
            // go to next view
            self.performSegueWithIdentifier("SampleListSegue", sender: self)
            // [[MEMELib sharedInstance] startDataReport]; is it needed?
            
        }.addDisposableTo(self.disposeBag)
        
        MEMELibAccess.sharedInstance.rx_memeDisconnected.subscribeNext { [unowned self] peripheral in
            print("meme disconnected")
            self.scanBtn.enabled = true
            self.tableView.userInteractionEnabled = true
            
            let alert:UIAlertController = UIAlertController(title: "Meme has disconnected", message: "for peripheral: \(peripheral.identifier.UUIDString)", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        }.addDisposableTo(self.disposeBag)

        /***** Other UI Components *****/

        self.scanBtn.rx_tap.subscribeNext({
            MEMELibAccess.scan()
        }).addDisposableTo(self.disposeBag)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if MEMELibAccess.sharedInstance.isConnected {
            // Disconnect JINS MEME everytime this view appears
            MEMELibAccess.disconnect()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Scan and select your JINS MEME"
        self.bindViewAndModel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

