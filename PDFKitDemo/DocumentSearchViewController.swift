//
//  DocumentSearchViewController.swift
//  PDFKitDemo
//
//  Created by Akshay Dochania on 11/04/20.
//  Copyright © 2020 app-developerz. All rights reserved.
//

import UIKit
import PDFKit

protocol DocumentSearchViewControllerDelegate: class {
    func searchViewController(_ searchViewController: DocumentSearchViewController, didSelectSearchResult selection: PDFSelection)
}

class DocumentSearchViewController: UIViewController {
        //MARK:- Variables
        var pdfDocument: PDFDocument?
        var searchResults = [PDFSelection]()
        weak var delegate: DocumentSearchViewControllerDelegate?
        
        //MARK:- Outlets
        @IBOutlet weak var tableView: UITableView!
        @IBOutlet weak var searchBar: UISearchBar!
        @IBOutlet weak var resultCountLabel: UILabel!
        
        deinit {
            pdfDocument?.cancelFindString()
            pdfDocument?.delegate = nil
        }
        
        //MARK:- Life cycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            //Tableview row height setup
            tableView.estimatedRowHeight = 88
            tableView.rowHeight = UITableView.automaticDimension
            searchBar.placeholder = "Search"
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            searchBar.becomeFirstResponder()
        }
    }

    //MARK:- UITableViewDelegate, UITableViewDataSource
    @available(iOS 11.0, *)
    extension DocumentSearchViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
            
            let selection = searchResults[indexPath.row]
            
            let extendedSelection = selection.copy() as! PDFSelection
            extendedSelection.extendForLineBoundaries()
            
            let page = selection.pages[0]
            cell.page = "Page \(page.label ?? "")"
            
            cell.resultText = extendedSelection.string
            cell.searchText = selection.string
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if searchResults.isEmpty {
                resultCountLabel.text = "No Result Found"
            } else {
                let resultString = searchResults.count > 1 ? "Results": "Result"
                resultCountLabel.text = "\(searchResults.count) \(resultString) Found"
            }
            return searchResults.count
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selection = searchResults[indexPath.row]
            searchBar.resignFirstResponder()
            delegate?.searchViewController(self, didSelectSearchResult: selection)
            tableView.deselectRow(at: indexPath, animated: true)
            dismiss(animated: true, completion: nil)
        }
    }

    //MARK:- UISearchBarDelegate, PDFDocumentDelegate
    @available(iOS 11.0, *)
    extension DocumentSearchViewController: UISearchBarDelegate, PDFDocumentDelegate{
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            dismiss(animated: true, completion: nil)
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            pdfDocument?.delegate = nil
            pdfDocument?.cancelFindString()
            
            let searchText = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces)
            if searchText.count >= 3 {//As we are searching in a pdf so we search for 3 or more characters
                resultCountLabel.isHidden = false
                searchResults.removeAll()
                tableView.reloadData()
                pdfDocument?.delegate = self
                pdfDocument?.beginFindString(searchText, withOptions: .caseInsensitive)
            }
        }
        
        func didMatchString(_ instance: PDFSelection) {
            searchResults.append(instance)
            tableView.reloadData()
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
        }
    }

