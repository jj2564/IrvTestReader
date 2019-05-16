//
//  ContentViewController.swift
//  irvTestReader
//
//  Created by Irving Huang on 2019/5/16.
//  Copyright © 2019 Irving Huang. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

    
    @IBOutlet weak var contentWebView: UIWebView!
    var contentPath: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let requestURL = URL(string: contentPath!)
        let request = URLRequest(url: requestURL!)
        contentWebView.loadRequest(request)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
