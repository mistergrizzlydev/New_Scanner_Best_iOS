//
//  StoryItem.swift
//  StoriesKit
//
//  Created by Elyscan.app on 2/26/21.
//

import UIKit

class Story {
  var storyIndex: Int = 0
  static var userIndex: Int = 0
  
  var items: [StoryItem]
  
  init(items: [StoryItem]) {
    self.items = items
  }
}

struct StoryFeature {
  let image: UIImage = UIImage(named: "logo")!
  let name: String
}

struct StoryItem {
  let image: UIImage
  let bgColor: UIColor
  let title: String
  let subtitle: String
  var textColor: UIColor = .white
  
  let storyFeature: StoryFeature
  
  static func getDummyData() -> [StoryItem] {
    return [ // UIImage(named: "1")! UIImage.gifImageWithName("hello")!
      StoryItem(image: UIImage(named: "1")!, bgColor: UIColor.colorFromRGB(rgbValue: 0x2567E3),
                title: "Welcome to \(Bundle.appName) Document Scanner".localized,
                subtitle: "This tiny yet powerful free scanner app is a must-have for students and anyone involved in a small business: accountants, realtors, managers, or lawyers.".localized,
                storyFeature: StoryFeature(name: "Welcome".localized)),
      
      StoryItem(image: UIImage(named: "2")!, bgColor: UIColor.colorFromRGB(rgbValue: 0xE7BE42),
                title: "Scan all kinds of documents".localized,
                subtitle: "Scan anything you need, including receipts, contracts, paper notes, fax papers, books, and store your scans as multipage PDF files. Scan one page or multiple pages at the same time with \(Bundle.appName).".localized,
                storyFeature: StoryFeature(name: "Scan anything".localized)),
      
      StoryItem(image: UIImage(named: "3")!, bgColor: UIColor.colorFromRGB(rgbValue: 0x363579),
                title: "Save time with smart workflows".localized,
                subtitle: "Perform common tasks with one tap, like saving a document to a specific folder or sharing it via email. Manage your files with folders, search, and organizational functions.".localized,
                storyFeature: StoryFeature(name: "Workflows".localized)),
      
      StoryItem(image: UIImage(named: "4")!, bgColor: UIColor.colorFromRGB(rgbValue: 0x53B16E),
                title: "Auto/manual camera document detection".localized,
                subtitle: "Just hold your mobile device over a document and let \(Bundle.appName) take the scan for you at the perfect moment.".localized,
                storyFeature: StoryFeature(name: "Camera".localized)),
      
      StoryItem(image: UIImage(named: "5")!, bgColor: UIColor.colorFromRGB(rgbValue: 0x307DF3),
                title: "Auto-rotation & perspective correction".localized,
                subtitle: "\(Bundle.appName)’s perspective correction straightens the scanned document before it gets converted into a PDF file.".localized,
                storyFeature: StoryFeature(name: "Perspective".localized)),
      
      StoryItem(image: UIImage(named: "6")!, bgColor: UIColor.colorFromRGB(rgbValue: 0x46A2CD),
                title: "Multi-Page Documents".localized,
                subtitle: "Digitize anything like a multi-page contract or several pages of meeting notes.".localized,
                storyFeature: StoryFeature(name: "PDFs".localized)),
      
      StoryItem(image: UIImage(named: "7")!, bgColor: UIColor.colorFromRGB(rgbValue: 0x8D959D),
                title: "Color Optimization".localized,
                subtitle: "You can optimize your scans for auto enhanced, black and white, grayscale and color.".localized,
                storyFeature: StoryFeature(name: "Filters".localized)),
      
      StoryItem(image: UIImage(named: "8")!, bgColor: UIColor.colorFromRGB(rgbValue: 0x48A9F3),
                title: "iCloud sync".localized,
                subtitle: "Sync all of your documents between your iPhone, iPad and Mac. Keep your documents handy when on-the-go. Scan a document on your iPhone or iPad and access it on all your other devices.".localized,
                storyFeature: StoryFeature(name: "Backup".localized)),
      
      StoryItem(image: UIImage(named: "9")!, bgColor: UIColor.colorFromRGB(rgbValue: 0x708BAA),
                title: "Text recognition".localized,
                subtitle: "The cutting-edge OCR (optical character recognition) technology automatically recognizes and extracts text from your scans. || Turn your scans into text, so you can read, copy, and export it to other apps. \(Bundle.appName) app supports 100+ languages. OCR (optical character recognition) feature extracts texts from single page for further editing or sharing.".localized,
                storyFeature: StoryFeature(name: "OCR".localized)),
      
      StoryItem(image: UIImage(named: "10")!, bgColor: UIColor.colorFromRGB(rgbValue: 0x2567E3),
                title: "Text Vision Plus".localized,
                subtitle: "Turn your scan into text, so you can read, copy, and export it to other apps.".localized,
                storyFeature: StoryFeature(name: "Feature".localized)),
      
      StoryItem(image: UIImage(named: "11")!, bgColor: UIColor.colorFromRGB(rgbValue: 0xE7BE42),
                title: "Full-text search".localized,
                subtitle: "Search trought the text of your scans to quickly find any document.".localized,
                storyFeature: StoryFeature(name: "Feature".localized)),
      
      StoryItem(image: UIImage(named: "12")!, bgColor: UIColor.colorFromRGB(rgbValue: 0xDC657C),
                title: "Passcode and TouchID".localized,
                subtitle: "Secure your app using FaceID or TouchID or Protect any document with a secure password.".localized,
                storyFeature: StoryFeature(name: "Security".localized)),
      
      StoryItem(image: UIImage(named: "13")!, bgColor: UIColor.colorFromRGB(rgbValue: 0x307DF3),
                title: "Draw & Highlight".localized,
                subtitle: "Highlight text with the marker or use the pen tool to draw on your documents Highlight the key parts of your document to not loose sight of them.".localized,
                storyFeature: StoryFeature(name: "Annotations".localized)),
      
      StoryItem(image: UIImage(named: "14")!, bgColor: UIColor.colorFromRGB(rgbValue: 0x8D953D),
                title: "Edit and Sign".localized,
                subtitle: "Highlight important information, attach comments or add your signature to any document.".localized,
                storyFeature: StoryFeature(name: "E-signature".localized)),
      
      StoryItem(image: UIImage(named: "15")!, bgColor: UIColor.colorFromRGB(rgbValue: 0x7961EC),
                title: "Add or Redact Text".localized,
                subtitle: "Add text to your document or safely redact existing text to hide confidential data.".localized,
                storyFeature: StoryFeature(name: "Text".localized)),
      
      StoryItem(image: UIImage(named: "16")!, bgColor: UIColor.colorFromRGB(rgbValue: 0xDF804E),
                title: "Quick Actions".localized,
                subtitle: "Act directly on information contained in your scans. You can call a number, open a URL or navigate to a place.".localized,
                storyFeature: StoryFeature(name: "Flexibility".localized)),
      
      StoryItem(image: UIImage(named: "17")!, bgColor: UIColor.colorFromRGB(rgbValue: 0x2567E3),
                title: "Share or print your documents".localized,
                subtitle: "Instantly print out docs in \(Bundle.appName) with nearby printer via AirPrint.".localized,
                storyFeature: StoryFeature(name: "Print document".localized)),
      
      StoryItem(image: UIImage(named: "18")!, bgColor: UIColor.colorFromRGB(rgbValue: 0xE35948),
                title: "Wifi transfer".localized,
                subtitle: "Without USB Wire & Cable: Transferring files in WiFi doesn't require the USB wires and cables and other apps like iTunes etc. Wi-Fi ready Connect to the same network of your PC and the app will pair automatically".localized,
                storyFeature: StoryFeature(name: "Transferring".localized)),
      
      StoryItem(image: UIImage(named: "19")!, bgColor: UIColor.colorFromRGB(rgbValue: 0xEFAF3F),
                title: "Siri shortcuts".localized,
                subtitle: "Siri Shortcuts are now available in \(Bundle.appName). Siri can detect the shortcuts to scan and help you import document via camera or library, or create a folder - a fast and easy workflow.".localized,
                storyFeature: StoryFeature(name: "Shortcuts".localized)),
      
      StoryItem(image: UIImage(named: "20")!, bgColor: UIColor.colorFromRGB(rgbValue: 0x54BB93),
                title: "Always have a tiny scanner with you.".localized,
                subtitle: "\(Bundle.appName) is a fast PDF Scanner that will become an indispensable tool in your everyday life. \nThis tiny yet powerful free scanner app is a must-have for students and anyone involved in a small business: accountants, realtors, managers, or lawyers. Scan anything you need, including receipts.".localized,
                storyFeature: StoryFeature(name: "Start using now!".localized))
    ]
  }
}
