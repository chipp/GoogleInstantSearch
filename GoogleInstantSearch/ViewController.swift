//
//  ViewController.swift
//  GoogleInstantSearch
//
//  Created by Vladimir Burdukov on 22/03/16.
//  Copyright © 2016 Vladimir Burdukov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    @IBOutlet private weak var keywordTextField: UITextField! {
        didSet {
            // Add left content padding for textField
            let padding = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 8, height: keywordTextField.frame.height)))
            keywordTextField.leftView = padding
            keywordTextField.leftViewMode = .Always
        }
    }
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        keywordTextField.rx_text.asDriver()
            // .throttle(0.5) – will wait 0.5s for new value from textField, if no value received – send latest value to subscriber
            // .distinctUntilChanged() – will forward value only if it changed in compare to previous value from textField
            .throttle(0.5).distinctUntilChanged()
            .flatMapLatest { keyword -> Driver<[NSAttributedString?]> in
                // if textField is empty then just clear tableView
                guard keyword.characters.count > 0 else {
                    return Observable.just([]).asDriver(onErrorJustReturn: [])
                }
                
                // in other case request network for list of suggestions
                return Observable.zip(Observable.just(keyword), Network.instance.suggestKeywork(keyword)) { keyword, suggestions -> [NSAttributedString?] in
                    // if no suggestions found then return NSAttributedString with "No results" message
                    guard suggestions.count > 0 else {
                        return [NSAttributedString(string: "No results")]
                    }
                    // then transform list of strings to list of NSAttributedString with keyword part highlighted
                    return suggestions.map { [weak self] suggest in
                        self?.highlightSearchTerm(keyword, inSuggestion: suggest)
                    }
                    // in case of error send to subcriber NSAttributedString with message
                }.asDriver(onErrorJustReturn: [NSAttributedString(string: "⚠️ Undefined error")])
            }
            // bind NSAttributedStrings array to table view as data source
            .drive(tableView.rx_itemsWithCellIdentifier("SuggestCell", cellType: UITableViewCell.self)) { (row, suggest, cell) in
                cell.textLabel?.attributedText = suggest
            }.addDisposableTo(disposeBag)
    }
    
    private func highlightSearchTerm(searchTerm: String?, inSuggestion suggestion: String) -> NSAttributedString? {
        guard let searchTerm = searchTerm else {
            return nil
        }
        
        let searchTermRange = (suggestion as NSString).rangeOfString(searchTerm, options: [.CaseInsensitiveSearch])
        let attributedString = NSMutableAttributedString(string: suggestion)
        
        if searchTermRange.length > 0 {
            attributedString.addAttributes([NSForegroundColorAttributeName : UIColor.grayColor()], range: searchTermRange)
        }
        
        return NSAttributedString(attributedString: attributedString)
    }

}

