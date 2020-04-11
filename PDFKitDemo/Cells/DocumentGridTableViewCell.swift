//
//  DocumentGridTableViewCell.swift
//  PDFKitDemo
//
//  Created by Akshay Dochania on 11/04/20.
//  Copyright © 2020 app-developerz. All rights reserved.
//

import UIKit

class DocumentGridCollectionViewCell: UICollectionViewCell {
    override var isHighlighted: Bool {
        didSet {
            imageView.alpha = isHighlighted ? 0.8 : 1
        }
    }
    var image: UIImage? = nil {
        didSet {
            imageView.image = image
        }
    }
    var pageNumber = 0 {
        didSet {
            pageNumberLabel.text = String(pageNumber)
        }
    }
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var pageNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pageNumberLabel.isHidden = false
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
}
