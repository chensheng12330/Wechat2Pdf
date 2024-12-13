//
//  ViewController.swift
//  WeChatArt2PDF
//
//  Created by sherwin chen on 2024/11/29.
//

import UIKit

class SHTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //self.tableView.backgroundColor = .white
        self.tableView.separatorStyle = .singleLine
        self.tableView.dataSource = self
        self.tableView.delegate = self
        //self.register(XLCityCell.self, forCellReuseIdentifier: "XLCityCellID")
        return
    }
    
    private var dataSource:Array<String> {
        return ["-> 生成PDF","-> 查看文档", "-> 设  置","-> 版  本 (1.0)"]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "XLCityCellID")
        cell.textLabel?.text = self.dataSource[indexPath.row]
        return cell
    }
    
    //#mark action
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // select Action
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.goToWeb2PdfVC()
    }
    
    func goToWeb2PdfVC() {
        
        //解析Json
        
        //按分类，做处理
        
        var  web2pdf = WebToPDFViewController(h5URL: "http://mp.weixin.qq.com/s?__biz=MzAxNDAyMzc0Mg==&mid=434819804&idx=1&sn=7f609a147e6f463c4d5009ca1391eebe&scene=21#wechat_redirect")
        self.navigationController?.pushViewController(web2pdf, animated: true)
        
        //处理完回调
        
        //回调将已下载完的标识完成，下次不再进行下载
        //下载失败的，记录到数据中，下次继续下载.
    }
}

