//
//  NameStorageManager.swift
//  WeChatArt2PDF
//
//  Created by sherwin chen on 2024/12/6.
//

import Foundation

// 定义数据结构
struct MainNode: Codable {
    let id:Int?
    let name: String?
    public var treeNode: [SubNode]?
}

struct SubNode: Codable {
    let id:Int?
    public var mainName: String?
    let name: String?
    let link: String?
}

class NameStorageManager {
    
    // 单例实例
    static let shared = NameStorageManager()
    
    // 文件存储路径
    private let namesFileURL: URL
    
    public var mainNodes:[MainNode]? // 原始hw100k.json网站数据结构
    public var loadNames:[String]? //已转换好的文章列表
    
    // 私有初始化方法，禁止外部创建实例
    private init(fileName: String = "names.json") {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.namesFileURL = documentDirectory.appendingPathComponent(fileName)
    }
    
    // 保存 name 列表到本地
    func saveNames(_ names: String) -> Bool {
        
        if self.loadNames != nil{
            self.loadNames?.append(names)
        }
        
        do {
            let namesData = try JSONSerialization.data(withJSONObject: self.loadNames ?? [], options:.prettyPrinted)
            try namesData.write(to: namesFileURL)
            print("Names saved to: \(namesFileURL.path)")
            return true
        } catch {
            print("Error saving names: \(error.localizedDescription)")
            return false
        }
        
        return true
    }
    
    // 读取存储的 name 字典
    func loadNamesFromFile() -> [String]? {
       do {
           // 检查文件是否存在
           guard FileManager.default.fileExists(atPath: namesFileURL.path) else {
               print("Names dictionary file does not exist.")
               return nil
           }
           
           // 读取文件数据
           let data  = try Data(contentsOf: namesFileURL)
           let names = try JSONSerialization.jsonObject(with: data, options: []) as? [String]
           return names
       } catch {
           print("Error reading names dictionary: \(error.localizedDescription)")
           return nil
       }
    }
    
    // 从 JSON 数据中提取 hw100k.json数据 列表
    func extractmainNodes() ->[MainNode]? {
        do {
            // 从工程文件中加载 JSON 数据
            self.loadNames = self.loadNamesFromFile() ?? []
            
            if let fileURL = Bundle.main.path(forResource: "hw100k", ofType: "json") {
                let jsonData = try Data(contentsOf: URL(filePath: fileURL))
                
                // 使用 JSONDecoder 解析数据
                let decoder = JSONDecoder()
                var tmpMainNodes:[MainNode] = try decoder.decode([MainNode].self, from: jsonData)
                
                //过滤掉，已经读取过的数据
                if(self.loadNames != nil){
                    // 将 arrayB 转换为 Set
                    // let setB = Set(self.loadNames)
                    
                    var index = 0;
                    for var tmpMainNode in tmpMainNodes { //分类
                        var filteredArray = tmpMainNode.treeNode?.filter { !(self.loadNames?.contains($0.name ?? ""))! }
                        
                        let sortedArray = filteredArray?.sorted { $0.id ?? 0 < $1.id ?? 0 }
                        //tmpMainNode.treeNode = sortedArray;
                        tmpMainNodes[index].treeNode = sortedArray;
                        
                        index += 1;
                        
                    }
                    
                }
                
                self.mainNodes = tmpMainNodes;
                
                print("\(String(describing: self.mainNodes))")
                
                return self.mainNodes
                
            } else {
                print("Error: Cannot find hw100k.json in the project.")
                return nil
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }
        return nil
    }
    
}
