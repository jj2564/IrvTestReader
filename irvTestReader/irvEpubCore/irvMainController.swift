//
//  irvMainController.swift
//  irvTestReader
//
//  Created by Irving Huang on 2019/5/13.
//  Copyright © 2019 Irving Huang. All rights reserved.
//

import UIKit

class irvMainController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    
    var book: IrvBook?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action:nil)
        let parser = IrvEpubParser()
        
        do {
            book = try parser.readEpub(fileName: "The_Silver_Chair")
        } catch  {
            
        }
        
        
        
    }
    

    
    
    
}

extension irvMainController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as? titleCell else {
            return UITableViewCell()
        }
        
        
        
        cell.titleLabel.text = "這是第\(index)欄"
        
        return cell
    }
}
