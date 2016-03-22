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
        // Do any additional setup after loading the view, typically from a nib.
        
        searchTerm.asObservable().flatMapLatest { keyword -> Observable<[String]> in
            guard let keyword = keyword else {
                return Observable.just([])
            }
            
            return Network.instance.suggestKeywork(keyword)
        }.bindTo(suggestions).addDisposableTo(disposeBag)
        
        suggestions.asDriver()
            .drive(tableView.rx_itemsWithCellIdentifier("SuggestCell", cellType: UITableViewCell.self)) { [weak self] (row, item, cell) in
                cell.textLabel?.attributedText = self?.highlightSearchTerm(self?.searchTerm.value, inSuggestion: item)
            }.addDisposableTo(disposeBag)
        
        searchTerm.value = "Engl"
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

