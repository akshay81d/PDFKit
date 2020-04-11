//
//  SearchTableViewCell.swift
//  PDFKitDemo
//
//  Created by Akshay Dochania on 11/04/20.
//  Copyright © 2020 app-developerz. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    var page: String? = nil {
        didSet {
            pageNumberLabel.text = page
        }
    }
    var resultText: String? = nil
    var searchText: String? = nil
    
    @IBOutlet private weak var pageNumberLabel: UILabel!
    @IBOutlet private weak var resultTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pageNumberLabel.textColor = .gray
        pageNumberLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        resultTextLabel.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let highlightRange = (resultText! as NSString).range(of: searchText!, options: .caseInsensitive)
        let attributedString = NSMutableAttributedString(string: resultText!)
        attributedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: resultTextLabel.font.pointSize)], range: highlightRange)
        attributedString.addAttribute(.backgroundColor, value: UIColor.yellow , range: highlightRange)
        resultTextLabel.attributedText = attributedString
    }
}
