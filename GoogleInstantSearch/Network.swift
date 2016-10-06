//
//  Network.swift
//  GoogleInstantSearch
//
//  Created by Vladimir Burdukov on 22/03/16.
//  Copyright © 2016 Vladimir Burdukov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Network {

  static let instance = Network()

  enum Error: ErrorType {
    case InvalidURL
    case InvalidResponse
  }

  func suggestKeyword(keyword: String) -> Observable<[String]> {
    // Create "cold" observable – request will be performed only when someone subscribes it
    return Observable.deferred { () -> Observable<[String]> in
      guard let baseURL = NSURL(string: "http://google.com/complete/search"),
        let url = self.url(baseURL, withParams: ["output" : "firefox", "q" : keyword]) else {
          return Observable.error(Error.InvalidURL)
      }

      return NSURLSession.sharedSession().rx_JSON(url).map { json in
        // api returns json in following form: ["keyword", ["suggest1", "suggest2"]]
        // we need only second part of this array
        guard let array = json as? [AnyObject] where array.count > 1,
          let suggest = array[1] as? [String] else {
            return []
        }

        return suggest
      }
    }
  }

  private func url(url: NSURL, withParams params: [String: String]) -> NSURL? {
    // add params with help of NSURLComponents
    // it will help us to perform all of percent escaping operations
    let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
    components?.queryItems = params.map(NSURLQueryItem.init)
    return components?.URL
  }

}
