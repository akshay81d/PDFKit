//
//  DocumentGridViewController.swift
//  PDFKitDemo
//
//  Created by Akshay Dochania on 11/04/20.
//  Copyright © 2020 app-developerz. All rights reserved.
//

import UIKit
import PDFKit

protocol DocumentGridViewControllerDelegate: class {
    func documentGridViewController(_ documentGridViewController: DocumentGridViewController, didSelectPage page: PDFPage)
    func backButtonTapped()
}

class DocumentGridViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomView: UIView!
    
    var pdfDocument: PDFDocument?
    var isFromSearch = false
    var isAttachment = false
    weak var delegate: DocumentGridViewControllerDelegate?
    weak var controllerRef: ViewController?
    
    let thumbnailCache = NSCache<NSNumber, UIImage>()
    
    
    var cellSize: CGSize {
        if let collectionView = collectionView {
            var width = collectionView.frame.width
            var height = collectionView.frame.height
            if width > height {
                swap(&width, &height)
            }
            width = (width - (20 * 4)) / 3
            height = width * 1.5
            return CGSize(width: width, height: height)
        }
        return CGSize(width: 100, height: 150)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomView.layer.borderColor = UIColor.gray.cgColor
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .gray
        collectionView?.backgroundView = backgroundView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK:- SearchButtonAction
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        let searchViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DocumentSearchViewController") as! DocumentSearchViewController
        searchViewController.pdfDocument = self.pdfDocument
        searchViewController.delegate = controllerRef
        self.present(searchViewController, animated: true) {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    //MARK:- FullPageViewButtonAction
    @IBAction func fullPageViewButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
}

extension DocumentGridViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pdfDocument?.pageCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DocumentGridCollectionViewCell", for: indexPath) as! DocumentGridCollectionViewCell
        
        if let page = pdfDocument?.page(at: indexPath.item) {
            let pageNumber = indexPath.item + 1//+1 for starting page no. from 1
            cell.pageNumber = pageNumber
            
            let key = NSNumber(value: pageNumber)
            if let thumbnail = thumbnailCache.object(forKey: key) {
                cell.image = thumbnail
            } else {
                let size = cellSize
                DispatchQueue.main.async {
                    let thumbnail = page.thumbnail(of: size, for: .cropBox)
                    self.thumbnailCache.setObject(thumbnail, forKey: key)
                    if cell.pageNumber == pageNumber {
                        DispatchQueue.main.async {
                            cell.image = thumbnail
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let page = pdfDocument?.page(at: indexPath.item) {
            delegate?.documentGridViewController(self, didSelectPage: page)
            self.navigationController?.popViewController(animated: false)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}

extension DocumentGridViewController {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

