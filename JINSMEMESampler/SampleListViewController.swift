//
//  SampleListViewController.swift
//  JINSMEMESampler
//
//  Created by Yuhei Miyazato on 12/3/15.
//  Copyright © 2015 mitolab. All rights reserved.
//

import Foundation
import UIKit

class SampleViewController: UITableViewController {
    
    var samples = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.samples = ["EyeBlink"]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SampleNameCell")
        cell!.textLabel!.text = self.samples[indexPath.row]
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.samples.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sb = UIStoryboard(name: samples[indexPath.row], bundle: nil)
        let vc = sb.instantiateInitialViewController()
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
