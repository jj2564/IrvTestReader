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
enum EpubError: Error, LocalizedError{
    case fullPathEmpty
    case bookNotAvailable
    
    public var errorDescription: String? {
        switch self {
        case .fullPathEmpty:
            return "Book corrupted"
        case .bookNotAvailable:
            return "Book not found"
        }
    }
}

internal let kApplicationDocumentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

public class IrvBook: NSObject {
    var fullPath: String?
    var version: Double?
    
    var metadata = IrvMetadata()
    var manifests = IrvManifests()
}

public class IrvMetadata {
    var creator = [String]()
    var publisher = [String]()
    var title = [String]()
    var identifier = [String]()
//    var dates = [String]()
    
    var language: String?
}
public class IrvManifests: NSObject {
    var manifests = [String : IrvManifest]()
    
    func add(_ manifest: IrvManifest) {
        self.manifests[manifest.href] = manifest
    }
    
    func findByProperty(_ properties: String) -> IrvManifest? {
        for manifest in manifests.values {
            if manifest.properties == properties {
                return manifest
            }
        }
        return nil
    }
}

public class IrvManifest {
    var id: String!
    var properties: String?
    var mediaType: String!
    var href: String!
}

class IrvEpubParser: NSObject {
    
    let book = IrvBook()
    
    /// Read Epub file
    /// 只取出封面 標題 章節 和基本內容
    /// - Parameter epubName:Only need to provide the fileName
    func readEpub (fileName epubName: String) throws  -> IrvBook  {
        let fileManager = FileManager.default
        
        var bookPath = ""
        bookPath = kApplicationDocumentsDirectory
        bookPath = bookPath.appendingPathComponent(epubName+".epub")
        
        guard fileManager.fileExists(atPath: bookPath) else {
            throw EpubError.bookNotAvailable
        }
        
        try readContainer(filePath: bookPath)
        try readOpf(filePath: bookPath)
        
        return self.book
    }
    
    ///先讀取第一層結構下的container.xml 這個目錄提供root file path
    /// - Parameter bookBasePath: The base book path
    /// - Throws: `EpubError`
    private func readContainer (filePath bookBasePath: String) throws{
        let containerPath = "META-INF/container.xml"
        let cPath = bookBasePath.appendingPathComponent(containerPath)
        let containerData = try Data(contentsOf: URL(fileURLWithPath: cPath), options: .alwaysMapped)
        let xmlDoc = try AEXMLDocument(xml: containerData)
        guard let fullPath = xmlDoc.root["rootfiles"]["rootfile"].attributes["full-path"] else {
            throw EpubError.fullPathEmpty
        }
        print(fullPath)
        //let mediaType = MediaType.by(fileName: fullPath)
        book.fullPath = fullPath
    }
    
    /// 分析 .opf 主要的結構在這
    /// - Parameter bookBasePath: The base book path
    /// - Throws: `EpubError`
    private func readOpf(filePath bookBasePath: String) throws {
        var identifier: String?
        
        let opfPath = bookBasePath.appendingPathComponent(book.fullPath!)
        let opfData = try Data(contentsOf: URL(fileURLWithPath: opfPath), options: .alwaysMapped)
        let xmlDoc = try AEXMLDocument(xml: opfData)
        

        if let package = xmlDoc.root.first {
            identifier = package.attributes["unique-identifier"]
            
            if let version = package.attributes["version"] {
                book.version = Double(version)
            }
        }

        // Parse "metadata"
        book.metadata = readMetadata(xmlDoc.root["metadata"].children)
        
        // Parse "manifest"
        xmlDoc.root["manifest"]["item"].all?.forEach {
            let manifest = IrvManifest()
            manifest.id = $0.attributes["id"] ?? ""
            manifest.properties = $0.attributes["properties"] ?? ""
            manifest.href = $0.attributes["href"] ?? ""
            manifest.mediaType = $0.attributes["media-type"] ?? ""
            
            book.manifests.add(manifest)
        }
    }
    
    /// Read and Parse Metadata
    /// - Returns: IrvMetadata
    private func readMetadata(_ tags: [AEXMLElement]) -> IrvMetadata {
        let metadata = IrvMetadata()
        
        for tag in tags {
//            print(tag)
            if tag.name == "dc:title" {
                metadata.title.append(tag.value ?? "")
                print("title = \(metadata.title)")
            }
            
            if tag.name == "dc:language" {
                let language = tag.value ?? metadata.language
                metadata.language = language != "en" ? language : metadata.language
            }
            
            if tag.name == "dc:creator" {
                metadata.creator.append(tag.value ?? "")
            }
            
            if tag.name == "dc:publisher" {
                metadata.publisher.append(tag.value ?? "")
            }
        }
        
        return metadata
    }
}

extension String {
    
    func appendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
}
