//
//  DataProvider.swift
//  GetCategories
//
//  Created by Hayk Movsesyan on 11/12/18.
//  Copyright © 2018 Hayk Movsesyan. All rights reserved.
//

import UIKit

protocol DataProviderDelegate: class {
    func didFinishDowloadImage(image: UIImage?, urlString: String)
    func downloadedImageWith(progress: Float, fileSize: String, urlString: String)
}

final class DataProvider: NSObject {
    
    private let host: String
    private let session: URLSession
    weak var delegate: DataProviderDelegate?
    
    init(host: String) {
        self.host = host
        session = URLSession(configuration: .default)
    }
    
    func getCategories(categoriesPath: String, completion: @escaping ([Category]) -> Void) {
        let url = URL(string: host + categoriesPath)!
        let task = self.session.dataTask(with: url) { (data, response, error) in
            if error == nil {
                if (response as! HTTPURLResponse).statusCode == 200 {
                    if data != nil {
                        if let object = (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)) as? [String: Any] {
                            var categories = [Category]()
                            let results = object["results"] as? [[String: Any]] ?? [[:]]
                            for result in results {
                                let id = result["id"] as! Int
                                let title = result["title"] as! String
                                let order = result["order"] as! Int
                                let category = Category.init(id: id, title: title, order: order)
                                categories.append(category)
                            }
                            DispatchQueue.main.async {
                                completion(categories)
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func getProduct(subCategoryId: Int, completion: @escaping ([Product]?) -> Void) {
        let url = URL(string: host + "/api/jin/product_by_categorieID/\(subCategoryId)/")!
        let task = self.session.dataTask(with: url) { (data, response, error) in
            if error == nil {
                if (response as! HTTPURLResponse).statusCode == 200 {
                    if data != nil {
                        if let object = (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)) as? [String: Any] {
                            var productList = [Product]()
                            
                            let results = object["results"] as? [[String: Any]] ?? [[:]]
                            for result in results {
                                let title = result["title"] as! String
                                let imageStringUrl = result["mainimg"] as! String
                                let product = Product(name: title, imageStringUrl: imageStringUrl)
                                productList.append(product)
                            }
                            DispatchQueue.main.async {
                                completion(productList)
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    lazy var dowloadSession: URLSession = {
        let netOperationQueue = OperationQueue()
        netOperationQueue.maxConcurrentOperationCount = 5
        let session = URLSession(configuration: .background(withIdentifier: "DowloadImage"), delegate: self, delegateQueue: netOperationQueue)
        return session
    }()
    
    func dowloadImageWithUrl(_ urlString: String) {
        let filePath = fileURL(urlString: urlString)
        if FileManager.default.fileExists(atPath: filePath.path) {
            createImageFrom(location: filePath, imageUrl: urlString)
        } else {
            let task = dowloadSession.downloadTask(with: URL(string: urlString)!)
            task.resume()
        }
    }
    
    private func imageName(stringUrl: String) -> String {
        return String(stringUrl.split(separator: "/").last!.split(separator: ".").first!)
    }
    
    private func fileURL(urlString: String) -> URL {
        let url = try! FileManager.default.url(for: .cachesDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: true)
        return url.appendingPathComponent(imageName(stringUrl: urlString))
    }
    
    private func createImageFrom(location: URL, imageUrl: String) {
        let data = try! Data(contentsOf: location)
    
        let image = UIImage(data: data)
        DispatchQueue.main.async {
            self.delegate?.didFinishDowloadImage(image: image, urlString: imageUrl)
        }
    }
}

extension DataProvider: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let imageUrl = downloadTask.originalRequest?.url?.absoluteString else { return }
        
        let filePath = fileURL(urlString: imageUrl)
        try! FileManager.default.copyItem(at: location, to: filePath)
        createImageFrom(location: location, imageUrl: imageUrl)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let urlString = downloadTask.originalRequest?.url?.absoluteString else { return }

        let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        let fileSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .binary)
        
        DispatchQueue.main.async {
            self.delegate?.downloadedImageWith(progress: progress, fileSize: fileSize, urlString: urlString)
        }
    }
}
