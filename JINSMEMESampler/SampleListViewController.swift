//
//  SampleListViewController.swift
//  JINSMEMESampler
//
//  Created by Yuhei Miyazato on 12/3/15.
//  Copyright © 2015 mitolab. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SampleListViewModel {
    var samples = Variable<[String]>([])
    
    init() {
        self.samples.value.append("DataView")
        self.samples.value.append("Spreadsheet")
        self.samples.value.append("Processing")
    }
}

class SampleViewController: UITableViewController {
    
    let viewModel = SampleListViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Sample List"
        
        // cellForRow~
        viewModel.samples.bindTo(self.tableView.rx_itemsWithCellIdentifier("SampleNameCell")) { _, sampleName, cell -> Void in
            cell.textLabel?.text = sampleName
        }.addDisposableTo(self.disposeBag)
        
        // tableview did selected
        self.tableView.rx_itemSelected.subscribeNext { [unowned self] indexPath in
            let sbName = self.viewModel.samples.value[indexPath.row]
            let vc = UIStoryboard(name: sbName, bundle: nil).instantiateInitialViewController()
            self.navigationController?.pushViewController(vc!, animated: true)
        }.addDisposableTo(self.disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
