//
//  ViewController.swift
//  irvTestReader
//
//  Created by Irving Huang on 2019/5/13.
//  Copyright © 2019 Irving Huang. All rights reserved.
//

import UIKit
import FolioReaderKit

class ViewController: UIViewController {
    
    let folioReader = FolioReader()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func openLibReader(_ sender: Any) {

        guard let bookPath = Bundle.main.path(forResource: "The_Silver_Chair", ofType: "epub") else {
            return
        }
        let config = FolioReaderConfig(withIdentifier: "book1")
        config.shouldHideNavigationOnTap = false
        let textColor = UIColor(red:0.86, green:0.73, blue:0.70, alpha:1.0)
        let customColor = UIColor(red:0.30, green:0.26, blue:0.20, alpha:1.0)
        let customQuote = QuoteImage(withColor: customColor, alpha: 1.0, textColor: textColor)
        config.quoteCustomBackgrounds.append(customQuote)
        
        folioReader.presentReader(parentViewController: self, withEpubPath: bookPath, andConfig: config, shouldRemoveEpub: false)
        
    }
}

