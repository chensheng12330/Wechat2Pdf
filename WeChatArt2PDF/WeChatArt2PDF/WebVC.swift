//
//  WebVC.swift
//  WeChatArt2PDF
//
//  Created by sherwin chen on 2024/11/29.
//

import Foundation
import UIKit
import WebKit


class WebToPDFViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView!
    
    var mainNodes:[MainNode]? // 原始hw100k.json网站数据结构
    var treeNode:SubNode?   //子节点元素
    
    var mainNodeIndex: Int? // 主Node Index
    var subNodeIndex: Int? // 子Node Index
    
    public var dirName: String? //分类名，用于目录
    public var links: Array<Dictionary<String, String>>? //链接模型
    
    public var artName: String? //文件名
    public var h5URL: String = "http://mp.weixin.qq.com/s?__biz=MzAxNDAyMzc0Mg==&mid=434819804&idx=1&sn=7f609a147e6f463c4d5009ca1391eebe&scene=21#wechat_redirect" // 替换为你的 H5 链接
    
    init(h5URL: String) {
        self.h5URL = h5URL
        super.init(nibName: nil, bundle: nil) // 调用父类的指定初始化方法
    }
    
    // 必须实现的解码初始化方法
    required init?(coder: NSCoder) {
        self.h5URL = ""
        self.mainNodeIndex = -1;
        self.subNodeIndex = -1;
        self.treeNode = nil;
        super.init(coder: coder)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        
        //加载本地数据
        json2treeNode()
        
        //准备开始
        
        
        //
        //loadH5Page(h5URL:self.h5URL)
    }
    
    func runLoopNodes(nodeIndex:Int, subIndex:Int) {
        if(nodeIndex >= self.mainNodes?.count ?? 0 ){
            return
        }
        
        if(subIndex >= self.mainNodes?[nodeIndex].treeNode?.count ?? 0 ){
            //尝试新节点
            self.mainNodeIndex! += 1
            self.subNodeIndex = 0
            
            self.runLoopNodes(nodeIndex: self.mainNodeIndex!, subIndex: self.subNodeIndex!)
            return
        }
        
        
        let treeNodeObj = self.mainNodes?[nodeIndex].treeNode?[subIndex] ?? nil
        if((treeNodeObj) != nil){
            //加载url数据
            if let url = treeNodeObj?.link {
                self.treeNode = treeNodeObj
                self.title = treeNodeObj?.name ?? ""
                self.loadH5Page(h5URL: url)
            }
        }
    }
    
    private func setupWebView() {
        let webViewConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: self.view.bounds, configuration: webViewConfiguration)
        webView.navigationDelegate = self
        self.view.addSubview(webView)
    }
    
    private func loadH5Page(h5URL:String) {
        if let url = URL(string: h5URL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    //已转pdf的文章记录
    // 定义函数来创建文件夹
    func createFolder(named name: String) ->(URL) {
        // 获取应用的文档目录路径
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // 创建目标文件夹路径
        let folderURL = documentDirectory.appendingPathComponent(name)
        
        // 检查文件夹是否已存在
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                // 创建文件夹
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                print("Folder created at: \(folderURL.path)")
            } catch {
                print("Error creating folder: \(error.localizedDescription)")
            }
        } else {
            print("Folder already exists: \(folderURL.path)")
        }
        
        return folderURL
        
    }
    
    func json2treeNode() {
        //NameStorageManager.shared.saveNames(["【基础知识】电源的分类","【基础知识】开关电源各种拓扑结构的特点"])
        self.mainNodes = NameStorageManager.shared.extractmainNodes()
        
        if self.mainNodes?.count ?? 0 > 0 {
            self.mainNodeIndex = 0
            self.subNodeIndex = 0
            self.runLoopNodes(nodeIndex: self.mainNodeIndex!, subIndex: self.subNodeIndex!)
        }
    }
    
    // 使用 createPDF 方法导出 PDF
    private func exportToPDF() {
        
        //滚动视图到底，确保图片加载完成
        self.exportFullPageToPDF()
        
        // 配置 PDF 生成
        let pdfConfig = WKPDFConfiguration()
        pdfConfig.rect = CGRect(x: 110, y: 0, width: webView.scrollView.contentSize.width-50, height: webView.scrollView.contentSize.height)

        // 调用 createPDF 方法
        webView.createPDF(configuration: pdfConfig) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.savePDFData(data: data)
            case .failure(let error):
                print("生成 PDF 失败: \(error)")
            }
        }
    }
    
    // 获取整个页面的截图并保存为 PDF
    private func exportFullPageToPDF() {
        // 获取页面的总内容高度
        let contentHeight = webView.scrollView.contentSize.height
        let screenWidth   = webView.bounds.width
        let screenHeight  = webView.bounds.height
        
        // 滚动并逐步截图
        let originalOffset = webView.scrollView.contentOffset
        var offsetY: CGFloat = 0
        
        while offsetY < contentHeight {
            webView.scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.3)) // 确保滚动完成
            
//            UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), nil)
//            webView.drawHierarchy(in: webView.bounds, afterScreenUpdates: true)
            
            offsetY += screenHeight
            Thread.sleep(forTimeInterval: 5)
        }
        
        // 恢复原始偏移量
        webView.scrollView.setContentOffset(originalOffset, animated: false)
        return
    }

    private func savePDFData(data: Data) {
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        // 获取网页标题并处理为合法文件名
        //let defaultFileName = "web_full_page"
        //let title = webView.title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? defaultFileName
        
        let sanitizedTitle   = sanitizeFileName(self.treeNode?.name ?? "")
        let sanitizedDirname = sanitizeFileName(self.mainNodes![self.mainNodeIndex!].name ?? "")
        
        let pdfPath = self.createFolder(named: sanitizedDirname).appendingPathComponent("\(self.treeNode?.id ?? 0)-\(sanitizedTitle).pdf")
        do {
            try data.write(to: pdfPath)
            print("PDF 文件已保存到: \(String(describing: pdfPath))")
    
            if( NameStorageManager.shared.saveNames(self.treeNode?.name ?? "") ){
                print("记录到文件已下载; \(self.treeNode?.name ?? "")")
            }
            //开始一个
            self.subNodeIndex! += 1;
            self.runLoopNodes(nodeIndex: self.mainNodeIndex!, subIndex: self.subNodeIndex!)
            
        } catch {
           print("保存 PDF 文件失败: \(error)")
        }
    }
    
    // 页面加载完成时导出 PDF
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("页面加载完成，开始导出全页面 PDF")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // 确保页面完全渲染
            self.exportToPDF()
        }
    }
    
    // 清理文件名，替换非法字符
   private func sanitizeFileName(_ name: String) -> String {
       let invalidCharacters = CharacterSet(charactersIn: "\\/:*?\"<>|")
       return name.components(separatedBy: invalidCharacters).joined(separator: "_")
   }
}
