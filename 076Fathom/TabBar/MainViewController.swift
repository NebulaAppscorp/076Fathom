//
//  MainViewController.swift
//  076Fathom
//
//  Created by Владимир on 5/20/26.
//

import UIKit
import SnapKit
import SwiftHelper
import Combine

class MainViewController: UITabBarController {
    
    let label = UILabel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        label.text = "Note AI"
        label.textColor = .black
        label.font = .systemFont(ofSize: 28, weight: .bold)
        
        let item = UIBarButtonItem(customView: label)
        label.snp.makeConstraints { make in
            make.width.equalTo(140)
            make.height.equalTo(34)
        }
        
        if #available(iOS 26, *) {
            item.hidesSharedBackground = true
        }
        
        navigationItem.leftBarButtonItem = item
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .fBG
        createTabs()
        checkOnboarding()
    }
    
    func checkOnboarding() {
        if UserDefaults.standard.object(forKey: "onborading") == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in 
                self?.openPaywall()
                UserDefaults.standard.set(1, forKey: "onborading")
            }
            
            
            let userHist = UserHistoryData(id: UUID(), type: .video, date: getTodayDate(), title: "🇺🇸 USA History", subTitle: "The film is a four-hour overview of the entire history of the United States — from the first peoples on the continent to events in 2024. The creators aim to present a coherent, continuous picture of the country’s development, using primarily authentic historical materials rather than AI-generated imagery.", summary: """
                🇺🇸 Brief summary of the documentary film
                The film is a four-hour overview of the entire history of the United States — from the first peoples on the continent to events in 2024. The creators aim to present a coherent, continuous picture of the country’s development, using primarily authentic historical materials rather than AI-generated imagery.
                
                🧭 Main stages covered in the video
                
                Pre-Columbian era
                A brief overview of the Indigenous peoples of North America, their cultures, and patterns of settlement.
                
                1492 and European colonization
                Christopher Columbus’s arrival, the subsequent European exploration and settlement of the continent, and the formation of British colonies.
                
                American Revolution and the birth of the nation
                Causes of the conflict with Britain, the War of Independence, and the creation of the Constitution.
                
                19th century: growth, expansion, and conflict
                Territorial expansion, industrialization, slavery, the Civil War, and its consequences.
                
                20th century: becoming a world power
                Participation in the World Wars, the Great Depression, the Cold War, and economic growth.
                
                Modern era
                Key events from the late 20th to the early 21st century, up to the 2024 elections.
                
                🎬 Film characteristics
                A very dense, fact-heavy narrative.
                
                Almost a year of work on the project.
                
                The YouTube version is about 10 minutes shorter due to platform requirements.
                
                The creators emphasize its educational purpose and commitment to historical accuracy.
                """, segm: [
                    .init(
                        start: 0,
                        end: 245,
                        text: "The film opens by defining its scope: a complete historical overview of the United States from ancient times to 2024. The goal is presented as creating a continuous, unified narrative of national development.",
                        speaker: "A"
                    ),

                    .init(
                        start: 245,
                        end: 612,
                        text: "The creators explain their approach: reliance on archival footage, historical records, maps, and authentic materials. Minimal use of artificial reconstruction, emphasis on accuracy and continuity.",
                        speaker: "B"
                    ),

                    .init(
                        start: 612,
                        end: 1084,
                        text: "Overview of the first human populations on the continent. Migration across the Bering land bridge and gradual settlement of North America over thousands of years.",
                        speaker: "B"
                    ),

                    .init(
                        start: 1084,
                        end: 1542,
                        text: "Development of diverse civilizations and tribal systems. Regional variation in lifestyle, economy, and social organization across North America, including trade networks and cultural exchange.",
                        speaker: "A"
                    ),

                    .init(
                        start: 1542,
                        end: 1935,
                        text: "Contextual background in Europe: growing maritime trade, competition for Asian trade routes, and advancements in navigation technology during the Age of Exploration.",
                        speaker: "B"
                    ),

                    .init(
                        start: 1935,
                        end: 2418,
                        text: "Preparation of the expedition under Spanish sponsorship. Political and economic motivations behind the voyage. Departure across the Atlantic Ocean.",
                        speaker: "A"
                    ),

                    .init(
                        start: 2418,
                        end: 3264,
                        text: "Initial encounters between Europeans and Indigenous populations. Early exchanges of goods, communication barriers, and the beginning of cultural and demographic disruption.",
                        speaker: "B"
                    ),

                    .init(
                        start: 3264,
                        end: 4518,
                        text: "Establishment of the first European settlements in the Americas. Rivalries between European powers such as Spain, England, and France begin to shape the continent’s future.",
                        speaker: "A"
                    ),

                    .init(
                        start: 4518,
                        end: 7200,
                        text: "Consolidation of European control in various regions. Emergence of colonial economies and governance structures that lay the foundation for later political conflicts.",
                        speaker: "B"
                    )
                ], isError: false, idBackend: "test")
            
            DataModel.shared.userHistory.append(userHist)
            DataModel.shared.dataFlowUser.saveArr(arr: DataModel.shared.userHistory)
            DataModel.shared.loaderPublisher.send(1)
        }
    }
    
    func createTabs() {
        let tab1 = UITabBarItem(title: "AI Tools", image: .tab1.resize(targetSize: .init(width: 36, height: 36)).withRenderingMode(.alwaysTemplate), tag: 0)
        let vc1 = AiToolsViewController()
        vc1.tabBarItem = tab1
        
        let tab2 = UITabBarItem(title: "Record", image: .tab2.resize(targetSize: .init(width: 36, height: 36)).withRenderingMode(.alwaysTemplate), tag: 2)
        let vc2 = UIViewController()
        vc2.tabBarItem = tab2
        
        let tab3 = UITabBarItem(title: "Settings", image: .tab3.resize(targetSize: .init(width: 36, height: 36)).withRenderingMode(.alwaysTemplate), tag: 3)
        let vc3 = SettingsViewController()
        vc3.tabBarItem = tab3
        
        viewControllers = [vc1, vc3]
        tabBar.tintColor = .fMain
        
        
    }
    
    
}
//сделать пэйволл + настройки и ai tools


enum SelectedType: String, Codable {
    case link = "Link"
    case audio = "Audio"
    case files = "Files"
    case video = "Video"
}
