//
//  APIManager.swift
//  home-s-on-fe
//
//  Created by songhee jeong on 12/1/24.
//
import Foundation

let BASE_URL = Bundle.main.infoDictionary?["BASE_URL"] ?? ""
let BLOB_URL = Bundle.main.infoDictionary?["BLOB_URL"] ?? ""

enum APIEndpoints {
    // 백엔드
    static let baseURL = BASE_URL
    
    // azure blob
    static let blobURL = BLOB_URL
}
