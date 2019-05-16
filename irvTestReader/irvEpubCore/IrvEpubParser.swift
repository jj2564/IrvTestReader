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


class IrvEpubParser: NSObject {
    
    let book = IrvBook()
//    private var dataBasePath = ""
    
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
        book.dataPath = bookBasePath.appendingPathComponent(book.fullPath!.deletingLastPathComponent)
    }
    
    /// 分析 .opf 主要的結構在這
    /// - Parameter bookBasePath: The base book path
    /// - Throws: `EpubError`
    private func readOpf(filePath bookBasePath: String) throws {
//        var identifier: String?
        
        let opfPath = bookBasePath.appendingPathComponent(book.fullPath!)
        let opfData = try Data(contentsOf: URL(fileURLWithPath: opfPath), options: .alwaysMapped)
        let xmlDoc = try AEXMLDocument(xml: opfData)
        

        if let package = xmlDoc.root.first {
//            identifier = package.attributes["unique-identifier"]
            
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
        
        if let cover = book.manifests.findByProperty("cover-image"){
            book.coverImage = cover
        }
        
        //目前只分析NCX一種目錄，所以讀其他書的格式會爆炸
        if let tocData = book.manifests.findByMediaType("application/x-dtbncx+xml") {
            book.tocFile = tocData.href
        }
        else {
            throw EpubError.noTocFile
        }
        
        // The book TOC
        book.tableOfContents = try findTableOfContents()
    }
    
    /// Read and Parse Metadata
    /// - Returns: IrvMetadata
    private func readMetadata(_ tags: [AEXMLElement]) -> IrvMetadata {
        let metadata = IrvMetadata()
        
        for tag in tags {
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
    
    /// Read and parse the Table of Contents.
    ///
    /// - Returns: A list of toc references
    private func findTableOfContents() throws -> [IrvTocReference] {
        var tableOfContent = [IrvTocReference]()
//        var tocItems: [AEXMLElement]?
        guard let tocFileName = book.tocFile else { return tableOfContent }
        let tocPath = book.dataPath!.appendingPathComponent(tocFileName)
        print(tocPath)
        
        
        let ncxData = try Data(contentsOf: URL(fileURLWithPath: tocPath), options: .alwaysMapped)
        let xmlDoc = try AEXMLDocument(xml: ncxData)
        if let itemsList = xmlDoc.root["navMap"]["navPoint"].all {
//            tocItems = itemsList
            
            ///這裡硬對結構之後再看看優化
            for item in itemsList{
                let tocItem = IrvTocReference()
//                print(item.children.last?.attributes["src"])
                tocItem.href = item.children.last?.attributes["src"]
//                print(item.children.first?.children.first?.value)
                tocItem.title = item.children.first?.children.first?.value
                tocItem.fullhref = book.dataPath!.appendingPathComponent(tocItem.href)
                tableOfContent.append(tocItem)
            }
            
        }
        
        return tableOfContent
    }
}

