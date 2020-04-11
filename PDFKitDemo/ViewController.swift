//
//  ViewController.swift
//  PDFKitDemo
//
//  Created by Akshay Dochania on 11/04/20.
//  Copyright © 2020 app-developerz. All rights reserved.
//

import UIKit
import PDFKit
import UIKit.UIGestureRecognizerSubclass

class ViewController: UIViewController {
    //MARK:- Outlets
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    //MARK:- Variables
//    var pageToOpen = PDFPage()
    var pdfDocument: PDFDocument?
    var selections: [PDFSelection]?
    let pdfViewGestureRecognizer = PDFViewGestureRecognizer()
    let barHideOnTapGestureRecognizer = UITapGestureRecognizer()
    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomView.layer.borderColor = UIColor.gray.cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(pdfViewPageChanged(_:)), name: .PDFViewPageChanged, object: nil)

        barHideOnTapGestureRecognizer.addTarget(self, action: #selector(gestureRecognizedToggleVisibility(_:)))
        barHideOnTapGestureRecognizer.delegate = self.pdfView
        //Gesture for hiding bottom controls
        pdfView.addGestureRecognizer(barHideOnTapGestureRecognizer)
        pdfView.addGestureRecognizer(pdfViewGestureRecognizer)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = UIColor.clear
        let url = Bundle.main.url(forResource: "pdf", withExtension: "pdf")!
        pdfView.document = PDFDocument(url: url)
        pdfDocument = pdfView.document
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePageNumberLabel()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    //MARK:- PDF View methods
    @objc func pdfViewPageChanged(_ notification: Notification) {
        if pdfViewGestureRecognizer.isTracking {
            hideBars()
        }
        updatePageNumberLabel()
    }
    
    private func updatePageNumberLabel() {
        if let currentPage = pdfView.currentPage, let index = pdfDocument?.index(for: currentPage), let pageCount = pdfDocument?.pageCount {
            pageNumberLabel.text = String(format: "%d/%d", index + 1, pageCount)
        } else {
            pageNumberLabel.text = nil
        }
    }
    
    private func hideBars() {
        if let _ = navigationController {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                self.bottomView.isHidden = true
            }
        }
    }
    
    private func showBars() {
        if let _ = navigationController {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                self.bottomView.isHidden = false
            }
        }
    }
    
    @objc func gestureRecognizedToggleVisibility(_ gestureRecognizer: UITapGestureRecognizer) {
        if navigationController != nil {
            if !bottomView.isHidden {
                hideBars()
            } else {
                showBars()
            }
        }
    }
    
    //MARK:- SearchButtonAction
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        let searchViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DocumentSearchViewController") as! DocumentSearchViewController
        searchViewController.pdfDocument = self.pdfDocument
        searchViewController.delegate = self
        searchViewController.modalPresentationStyle = .overCurrentContext
        self.present(searchViewController, animated: true, completion: nil)
    }
    
    //MARK:- GridViewButtonAction
    @IBAction func gridViewButtonTapped(_ sender: UIButton) {
        let documentGridViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DocumentGridViewController") as! DocumentGridViewController
        documentGridViewController.delegate = self
        documentGridViewController.pdfDocument = self.pdfDocument
        documentGridViewController.modalTransitionStyle = .crossDissolve
        documentGridViewController.modalPresentationStyle = .overCurrentContext
        self.navigationController?.pushViewController(documentGridViewController, animated: false)
    }
}

class PDFViewGestureRecognizer: UIGestureRecognizer {
    var isTracking = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = false
    }
}

//MARK:- DocumentSearchViewControllerDelegate
extension ViewController: DocumentSearchViewControllerDelegate {
    func searchViewController(_ searchViewController: DocumentSearchViewController, didSelectSearchResult selection: PDFSelection) {
        pdfView.go(to: selection)
        showBars()
        
        let highlight = PDFAnnotation(bounds: selection.bounds(for: selection.pages.first!), forType: .highlight, withProperties: nil)
        highlight.endLineStyle = .square
        highlight.color = .yellow
            
        selection.pages.first?.addAnnotation(highlight)
    }
}

//MARK:- DocumentGridViewControllerDelegate
@available(iOS 11.0, *)
extension ViewController: DocumentGridViewControllerDelegate {
    func backButtonTapped() {
        self.navigationController?.popViewController(animated: false)
    }
    
    func documentGridViewController(_ documentGridViewController: DocumentGridViewController, didSelectPage page: PDFPage) {
        pdfView.go(to: page)
    }
}

extension ViewController {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    //MARK:- iOS 13 support
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

