//
//  IrvEpubParser.swift
//  irvTestReader
//
//  Created by Irving Huang on 2019/5/14.
//  Copyright © 2019 Irving Huang. All rights reserved.
//

import UIKit
import AEXML
import SSZipArchive

//先定義錯誤到時候再增加
enum EpubError: Error {
    case timeout
}

class IrvEpubParser: NSObject {

    
    func readEpub (fileName epubName: String) {
        let fileManager = FileManager.default
        
//        let basePath = Bundle.main.bundlePath
//
//        print(basePath)
        
        guard let bookPath = Bundle.main.path(forResource: epubName, ofType: "epub") else {
            return
        }
        
        guard fileManager.fileExists(atPath: bookPath) else {
            return
        }
        
        
    }
    
    //先讀取第一層結構下的Container
    func readContainer (filePath bookBasePath: String) throws {
        let containerPath = "META-INF/container.xml"
        let containerData = try Data(contentsOf: URL(fileURLWithPath: bookBasePath.appendingPathComponent(containerPath)), options: .alwaysMapped)
        let xmlDoc = try AEXMLDocument(xml: containerData)
    }
}

extension String {
    
    func appendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
}
