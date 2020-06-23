//
//  FileDownload.swift
//  PayProGlobalStore
//
//  Created by Srinivas Prabhu G on 23/06/20.
//  Copyright © 2020 PayPro Global Inc. All rights reserved.
//

import Foundation

internal func fileDownload(at url: URL, destinationFileName:String, completion: @escaping (String?, Error?) -> Void)
{
    let documentsUrl =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    let destinationUrl = documentsUrl.appendingPathComponent(destinationFileName)

    do {
        if FileManager().fileExists(atPath: destinationUrl.path){
            try FileManager().removeItem(atPath: destinationUrl.path)
        }
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request, completionHandler:{ (data, response, error) in
            DispatchQueue.main.async {
                guard error == nil, let valid = response as? HTTPURLResponse,valid.statusCode == 200 else {
                    completion(nil, error)
                    return
                }
                do {
                    if let _ = try data?.write(to: destinationUrl, options: Data.WritingOptions.atomic){
                        completion(destinationUrl.path, nil)
                    }
                } catch let error {
                    completion(nil,error)
                }
            }
        })
        task.resume()
    } catch let error {
        completion(nil, error)
    }
}
