//
//  DataModel.swift
//  076Fathom
//
//  Created by Владимир on 5/25/26.
//

import Foundation
import UIKit
import Combine

class   DataModel {
    
    
    init() {
        startCheckGenerate()
    }
    
    static let shared = DataModel()
    
    let dataFlowUser = DataFlowUser()
    
    lazy var userHistory: [UserHistoryData] = dataFlowUser.loadHistoryArrFromFile() ?? []
    
    let loaderPublisher = PassthroughSubject<Any,Never>()
    
    let netModel = NetworkModel()
    
    
    var timers: [String: Timer] = [:]
    
    
    func startCheckGenerate() {
        
        for item in userHistory {
            
            guard item.isError == false,
                  item.summary == nil else { continue }
            
            checkStatusNow(id: item.idBackend)
            startTimerForItem(id: item.idBackend)
        }
    }

    func checkStatusNow(id: String) {
        
        netModel.fetchStatus(idGenerate: id) { [weak self] status in
            
            guard let self = self else { return }
            guard let status = status else { return }
            
            DispatchQueue.main.async {
                
                guard let index = self.userHistory.firstIndex(where: {
                    $0.idBackend == id
                }) else {
                    return
                }
                
                print(status.status)
                
                if status.status == "completed" {
                    
                    self.userHistory[index].summary =
                        status.summaryDetailed
                    
                    self.userHistory[index].segm =
                        status.segments
                    
                    self.userHistory[index].title =
                        status.summaryDetailed ?? ""
                    
                    self.userHistory[index].subTitle =
                        status.summaryDetailed ?? ""
                    
                    self.dataFlowUser.saveArr(arr: self.userHistory)
                    
                    self.loaderPublisher.send(true)
                    
                    self.timers[id]?.invalidate()
                    self.timers[id] = nil
                }
                
                if status.status == "failed" {
                    
                    self.userHistory[index].isError = true
                    
                    self.dataFlowUser.saveArr(arr: self.userHistory)
                    
                    self.loaderPublisher.send(true)
                    
                    self.timers[id]?.invalidate()
                    self.timers[id] = nil
                }
            }
        }
    }


    
    func startTimerForItem(id: String) {
           
           if timers[id] != nil {
               return
           }
           
           let timer = Timer.scheduledTimer(
               withTimeInterval: 30,
               repeats: true
           ) { [weak self] timer in
               
               guard let self = self else { return }
               
               self.netModel.fetchStatus(idGenerate: id) { status in
                   
                   guard let status = status else { return }
                   
                   DispatchQueue.main.async {
                       
                       guard let index = self.userHistory.firstIndex(where: {
                           $0.idBackend == id
                       }) else {
                           return
                       }
                       
                       print(status.status)
                       
                       if status.status == "completed" {
                           
                           self.userHistory[index].summary =
                           status.summaryDetailed
                           
                           self.userHistory[index].segm = status.segments
                           
                           self.userHistory[index].title = status.summaryDetailed ?? ""
                           self.userHistory[index].subTitle = status.summaryDetailed ?? ""
                           
                           self.dataFlowUser.saveArr(arr: self.userHistory)
                           
                           self.loaderPublisher.send(true)
                           
                           timer.invalidate()
                           self.timers[id] = nil
                       }
                       
                       if status.status == "failed" {
                           
                           self.userHistory[index].isError = true
                           
                           self.dataFlowUser.saveArr(arr: self.userHistory)
                           
                           self.loaderPublisher.send(true)
                           
                           timer.invalidate()
                           self.timers[id] = nil
                       }
                   }
               }
           }
           
           timers[id] = timer
       }
   
    
    
}

class DataFlowUser {
    
    func loadHistoryArrFromFile() -> [UserHistoryData]? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("DataFlowUser.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let arr = try JSONDecoder().decode([UserHistoryData].self, from: data)
            return arr
        } catch {
            print("Failed to load or decode athleteArr: \(error)")
            return nil
        }
    }
    
    private func saveArrToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("DataFlowUser.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
    
    func saveArr(arr: [UserHistoryData]) {
        do {
            let data = try JSONEncoder().encode(arr) //тут мкассив конвертируем в дату
            try saveArrToFile(data: data)
        } catch {
            print("Failed to encode or save athleteArr: \(error)")
        }
    }
}



struct UserHistoryData: Codable, Identifiable {
    let id: UUID
    
    let type: SelectedType
    let date: String
    
    var title: String
    var subTitle: String
    
    var summary: String?
    var segm: [Segment]? // менять
    
    var isError: Bool
    var idBackend: String
    
}
