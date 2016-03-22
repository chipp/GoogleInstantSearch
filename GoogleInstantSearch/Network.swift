//
//  Network.swift
//  GoogleInstantSearch
//
//  Created by Vladimir Burdukov on 22/03/16.
//  Copyright © 2016 Vladimir Burdukov. All rights reserved.
//

import UIKit
import RxSwift

class Network {
    
    static let instance = Network()
    
//    http://google.com/complete/search?output=firefox&q=keyword
    func suggestKeywork(keyword: String) -> Observable<[String]> {
        return Observable.empty()
    }

}
