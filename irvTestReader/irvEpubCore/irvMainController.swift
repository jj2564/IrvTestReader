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
            self.navigationItem.title = book?.metadata.title.first
            mainTableView.reloadData()
        } catch  {
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "presentContent" {
            
            let indexPath = mainTableView.indexPathForSelectedRow!
            let destVC = segue.destination as! ContentViewController
            destVC.contentPath = book?.tableOfContents[indexPath.row-1].fullhref
            

        }
    }
}

extension irvMainController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count =  book?.tableOfContents.count else {
            return 0
        }
        return  count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        
        
        if index == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "coverCell", for: indexPath) as? coverCell else {
                return UITableViewCell()
            }
            
            let imagePath = book!.dataPath!.appendingPathComponent(book!.coverImage!.href)
            
            cell.coverImageView.image = UIImage(contentsOfFile: imagePath)
            
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as? titleCell else {
                return UITableViewCell()
            }
            
            
            let tocItem = book?.tableOfContents[index-1]
            cell.titleLabel.text = tocItem?.title
            
            return cell
        }
        
    }
}
