//
//  ViewController.swift
//  GoogleInstantSearch
//
//  Created by Vladimir Burdukov on 22/03/16.
//  Copyright © 2016 Vladimir Burdukov. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    @IBOutlet private weak var keywordTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    private let suggestions = Variable<[String]>([])
    private let searchTerm = Variable<String?>(nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        keywordTextField.rx_text.asDriver()
            .throttle(0.5).distinctUntilChanged()
            .flatMapLatest { keyword in
                Observable.zip(Observable.just(keyword), Network.instance.suggestKeywork(keyword)) { keyword, suggestions in
                    suggestions.map { [weak self] suggest in
                        self?.highlightSearchTerm(keyword, inSuggestion: suggest)
                    }
                    }.asDriver(onErrorJustReturn: [NSAttributedString(string: "❌ No results")])
            }.drive(tableView.rx_itemsWithCellIdentifier("SuggestCell", cellType: UITableViewCell.self)) { (row, suggest, cell) in
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

