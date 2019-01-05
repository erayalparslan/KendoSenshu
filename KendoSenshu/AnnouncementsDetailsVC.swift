//
//  AnnouncementsDetailsVC.swift
//  KendoSenshu
//
//  Created by ruroot on 10/29/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit

class AnnouncementsDetailsVC: UIViewController {
    
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!

    
    
    var record: Announcement = Announcement()
    var images: [UIImage] = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitial()
        loadDetails()
    }

    func setInitial(){
        self.descriptionTextView.text = ""
    }
    

    
    func loadDetails() {
        calendarLabel.text         = record.date
        categoryLabel.text         = record.category
        titleLabel.text            = record.title
        
        
        
        let htmlStringData = record.description.data(using: String.Encoding.utf8)!
        
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            NSAttributedString.DocumentReadingOptionKey(rawValue: NSAttributedString.DocumentAttributeKey.documentType.rawValue): NSAttributedString.DocumentType.html,
            NSAttributedString.DocumentReadingOptionKey(rawValue: NSAttributedString.DocumentAttributeKey.characterEncoding.rawValue): String.Encoding.utf8.rawValue
        ]
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            // perform in background thread
            let attributedString = try! NSAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
            
            DispatchQueue.main.async {
                // handle text in main thread
                let stringWithoutHTMLTags = attributedString.string
                self.descriptionTextView.text = stringWithoutHTMLTags
                self.images = self.loadimages(for: self.record.description)
                if !self.images.isEmpty {
                    self.mImageView.image = self.images[0]
                    
                }
                else {
                    print("No image available")
                }
            }
            
        }
        
        
    }
    
    func loadimages(for text: String) -> [UIImage] {
        let matched = matches(for: "(http[^\\s]+(jpg|jpeg|png|tiff)\\b)", in: String(text))
        var images = [UIImage]()
        for item in matched {
            print(item)
            let data = try? Data(contentsOf: URL(string: item)!)
            
            if let imageData = data {
                if let image = UIImage(data: imageData) {
                    images.append(image)
                }
                else {
                    print("probably there is no image available")
                }
            }
            else {
                print("image could not be fetched")
            }
        }
        return images
    }
    
    
    func matches(for regex: String!, in text: String!) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
}
extension String {
    func deleteHTMLTag(tag:String) -> String {
        return self.replacingOccurrences(of: "(?i)</?\(tag)\\b[^<]*>", with: "", options: .regularExpression, range: nil)
    }
    
    func deleteHTMLTags(tags:[String]) -> String {
        var mutableString = self
        for tag in tags {
            mutableString = mutableString.deleteHTMLTag(tag: tag)
        }
        return mutableString
    }
}
