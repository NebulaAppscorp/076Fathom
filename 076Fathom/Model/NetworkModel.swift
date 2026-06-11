//
//  NetworkModel.swift
//  076Fathom
//
//  Created by Владимир on 5/26/26.
//

import Foundation
import ApphudSDK
import Alamofire

class NetworkModel {
    
    func sendTranscript(urlData: URL, type: SelectedType, escaping: @escaping(String?) -> Void) {
        let idApphud = Apphud.userID()
        let endpoint = "https://nebulaapps.site/Descript/transcriptions/process?user_id=\(idApphud)&app_id=com.estna.fagila"
        
        let fileName = urlData.lastPathComponent
        let mimeType = urlData.pathExtension.lowercased()
        
        let bearerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOiJzaGFyb3ZfMTk5OUBsaXN0LnJ1Iiwicm9sZSI6IkFETUlOIiwiZXhwIjo0OTI3NjIyOTM5LCJpYXQiOjE3NzQwMjI5MzksInR5cGUiOiJhY2Nlc3MifQ.M6wcypBTl8MJGUvPLAzCU1Yv-QTmxrKJ2CaR1VG0jeI"
        
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer \(bearerToken)"
        ]
        
        AF.upload(
            multipartFormData: { multipartFormData in
                
                if type == .link {
                    multipartFormData.append(
                        urlData.absoluteString.data(using: .utf8)!,
                        withName: "url"
                    )
                } else {
                    multipartFormData.append(
                        urlData,
                        withName: "file",
                        fileName: fileName,
                        mimeType: mimeType
                    )
                }
            },
            to: endpoint, method: .post,
            headers: headers
        ).uploadProgress { progress in
            
            print(progress.fractionCompleted)
            
            let percent = Int(progress.fractionCompleted * 100)
            
            print("\(percent)%")
        }.responseData { response in
            debugPrint(response)
            
            switch response.result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(SendResponse.self, from: data)
                    escaping("\(decoded.job_id)")
                } catch {
                    escaping(nil)
                    print("DECODING ERROR:", error)
                }
                
            case .failure(let error):
                print("ERROR:", error)
                escaping(nil)
            }
        }
    }
    
     
    func fetchStatus(idGenerate: String, escaping: @escaping(StatusRequest?) -> Void) {
        let idApphud = Apphud.userID()
        let bearerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOiJzaGFyb3ZfMTk5OUBsaXN0LnJ1Iiwicm9sZSI6IkFETUlOIiwiZXhwIjo0OTI3NjIyOTM5LCJpYXQiOjE3NzQwMjI5MzksInR5cGUiOiJhY2Nlc3MifQ.M6wcypBTl8MJGUvPLAzCU1Yv-QTmxrKJ2CaR1VG0jeI"
        
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer \(bearerToken)"
        ]
        
        let endpoint = "https://nebulaapps.site/Descript/transcriptions/\(idGenerate)?type=detailed&user_id=\(idApphud)&app_id=com.estna.fagila"
        
        AF.request(endpoint, method: .get, headers: headers).responseData { response in
            debugPrint(response)
            switch response.result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(StatusRequest.self, from: data)
                    escaping(decoded)
                } catch {
                    print("ERROR:", error)
                    escaping(nil)
                }
                
            case .failure(let error):
                print("ERROR:", error)
                escaping(nil)
            }
        }
        
        
    }
    
    
    
}


struct SendResponse: Decodable {
    let job_id: Int
}


struct StatusRequest: Codable {
    let id: Int
    let status: String
    let userId: String
    let fileKey: String
    let hasTranscript: Bool?
    let durationSeconds: Double?
    let errorMessage: String?
    
    let segments: [Segment]?
    let fullText: String?
    
    let cleanedKey: String?
    let cleanedURL: String?
    
    let summaryType: String?
    let summaryShort: String?
    let summaryDetailed: String?
    let summaryBullets: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case userId = "user_id"
        case fileKey = "file_key"
        case hasTranscript = "has_transcript"
        case durationSeconds = "duration_seconds"
        case errorMessage = "error_message"
        case segments
        case fullText = "full_text"
        case cleanedKey = "cleaned_key"
        case cleanedURL = "cleaned_url"
        case summaryType = "summary_type"
        case summaryShort = "summary_short"
        case summaryDetailed = "summary_detailed"
        case summaryBullets = "summary_bullets"
    }
}

struct Segment: Codable {
    let start: Double
    let end: Double
    let text: String
    let speaker: String?
}
