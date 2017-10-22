//
//  URLSession+Task.swift
//  LyricsProvider
//
//  Created by 邓翔 on 2017/10/22.
//

import Foundation

extension URLSession {
    
    func dataTask<T: Decodable>(with request: URLRequest, type: T.Type, completionHandler: @escaping (_ model: T?, _ error: Error?) -> Void) -> URLSessionDataTask {
        return dataTask(with: request) { data, response, error in
            do {
                if let error = error { throw error }
                guard let data = data else {
                    completionHandler(nil, nil)
                    return
                }
                let model = try JSONDecoder().decode(T.self, from: data)
                completionHandler(model, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
    func dataTask<T: Decodable>(with url: URL, type: T.Type, completionHandler: @escaping (_ model: T?, _ error: Error?) -> Void) -> URLSessionDataTask {
        return dataTask(with: url) { data, response, error in
            do {
                if let error = error { throw error }
                guard let data = data else {
                    completionHandler(nil, nil)
                    return
                }
                let model = try JSONDecoder().decode(T.self, from: data)
                completionHandler(model, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
}
