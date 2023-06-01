//
//  SearchViewController.swift
//  NasaSearchAPI
//
//  Created by Michael A Edgcumbe on 6/1/23.
//

import UIKit

class SearchViewController: UIViewController {

    internal var model:SearchViewModel = SearchViewModel()
    internal var lastQuery:String = "apollo 11"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        model.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateModel(with: lastQuery)
    }
    
    public func updateModel(with query:String, on page:Int = 1) {
        let _ = Task.init(priority: .userInitiated) {
            do {
                try await model.search(for:query, page:page)
            } catch {
                // report error to logging
                print(error)
            }
        }
    }
}

extension SearchViewController : SearchViewModelDelegate {
    public func modelDidUpdate(with response: NASASearchResponse) {
        let items = response.collection.items
        for item in items {
            for link in item.links {
                print(link.href)
            }
            print(item.data)
        }
    }
}

