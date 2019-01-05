//
//  AnnouncementsVC.swift
//  KendoSenshu
//
//  Created by ruroot on 10/28/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit

class AnnouncementsVC: UIViewController {

    @IBOutlet weak var mTableView: UITableView!
    
    var aa: DispatchGroup = DispatchGroup()
    let newsURL = "http://www.kendo-tr.com/feed/"
    var rssRecordList: [Announcement] = [Announcement]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        
       
        ProgressHUD.show()
        let queue = DispatchQueue(label: "tableDataQueue")
        queue.async() {
            self.loadData()
            DispatchQueue.main.async {
                self.mTableView.reloadData()
            }
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = mTableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath {
                //the last element is displayed
                ProgressHUD.dismiss()
            }
        }
    }

    func loadData(){
        if let rssURL = URL(string: self.newsURL) {
            if let xmlToParse = try? Data(contentsOf: rssURL) {
                let xml = SWXMLHash.parse(xmlToParse)
                for elem in xml["rss"]["channel"]["item"].all {
                    let rssRecord: Announcement = Announcement()
                   
                    rssRecord.title       = elem["title"].element!.text
                    rssRecord.date        = String(elem["pubDate"].element!.text.prefix(16))
                    rssRecord.description = elem["content:encoded"].element!.text
                    rssRecord.category    = elem["category"].element!.text
                    self.rssRecordList.append(rssRecord)
                }
            }
        }
    }
    
    func setDelegates() {
        mTableView.delegate  = self
        mTableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newsDetailSegue" {
            let selectedIndexPath : [IndexPath] = mTableView.indexPathsForSelectedRows!
            mTableView.deselectRow(at: selectedIndexPath[0], animated: true)
            let nextVC = segue.destination as! AnnouncementsDetailsVC
            nextVC.record = rssRecordList[selectedIndexPath[0].row]
        }
    }
    
    
    
}
extension AnnouncementsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rssRecordList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mTableView.dequeueReusableCell(withIdentifier: "newsCell") as! NewsTableCell
        let theRecord : Announcement  = rssRecordList[indexPath.row]
        
        cell.titleLabel.text = theRecord.title
        cell.dateLabel.text  = theRecord.date
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    
    
}
