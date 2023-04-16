//
//  PDFView+Extensions.swift
//  Project
//
//  Created by Mister Grizzly on 15.04.2023.
//

import PDFKit
import UIKit

extension PDFView {
  func configure(displayDirection: PDFDisplayDirection = .horizontal, autoScales: Bool = true, displayMode: PDFDisplayMode = .singlePage) {
    autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.displayMode = displayMode
    self.displayDirection = displayDirection
    self.autoScales = autoScales
    usePageViewController(true, withViewOptions: [UIPageViewController.OptionsKey.interPageSpacing: 10])
    
   subviews.forEach { subview in
      if let scrollView = subview.subviews.first as? UIScrollView {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
      }
    }
  }
}
