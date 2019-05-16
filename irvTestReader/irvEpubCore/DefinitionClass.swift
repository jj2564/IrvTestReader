//
//  DefinitionClass.swift
//  irvTestReader
//
//  Created by Irving Huang on 2019/5/16.
//  Copyright © 2019 Irving Huang. All rights reserved.
//

import UIKit

//先定義錯誤到時候再增加
enum EpubError: Error, LocalizedError{
    case fullPathEmpty
    case bookNotAvailable
    case noTocFile
    
    public var errorDescription: String? {
        switch self {
        case .fullPathEmpty:
            return "Book corrupted"
        case .bookNotAvailable:
            return "Book not found"
        case .noTocFile:
            return "Book not found Toc file"
        }
    }
}

internal let kApplicationDocumentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

public class IrvBook: NSObject {
    var fullPath: String?
    var dataPath: String?
    var version: Double?
    
    var metadata = IrvMetadata()
    var manifests = IrvManifests()
    
    var coverImage: IrvManifest?
    
    var tocFile: String?
    public var tableOfContents: [IrvTocReference]!
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
    
    func findByMediaType(_ mediaType: String) -> IrvManifest? {
        for manifest in manifests.values {
            if manifest.mediaType != nil && manifest.mediaType == mediaType {
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

public class IrvTocReference: NSObject {
    public var title: String!
    public var href: String!
    public var fullhref: String!
//    public var resource: IrvManifest?
}

extension String {
    
    func appendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
    
    var deletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
    
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
}
