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
    
    private let searchBarContainerViewHeight:CGFloat = 48 + 16
    private let searchBarEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: -8, right: -20)
    private var searchBarContainerView:UIView = UIView(frame:.zero)
    private var searchBarTextField:UISearchTextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        model.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        buildSearchBarContainerView(with: lastQuery)
        updateModel(with: lastQuery)
    }
}

extension SearchViewController {
    internal func updateModel(with query:String, on page:Int = 1) {
        let _ = Task.init(priority: .userInitiated) {
            do {
                try await model.search(for:query, page:page)
            } catch {
                // report error to logging
                print(error)
            }
        }
    }

    internal func buildSearchBarContainerView(with query:String) {
        searchBarContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBarContainerView)
        searchBarContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        searchBarContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        searchBarContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBarContainerView.heightAnchor.constraint(equalToConstant:searchBarContainerViewHeight).isActive = true
        
        searchBarTextField = UISearchTextField(frame: .zero, primaryAction: UIAction(title: "Search", handler: { [unowned self] action in
            if let text = searchBarTextField?.text {
                updateModel(with: text)
            }
            
            searchBarTextField?.resignFirstResponder()
        }))
        
        searchBarTextField?.translatesAutoresizingMaskIntoConstraints = false
        searchBarContainerView.addSubview(searchBarTextField!)
        searchBarTextField!.leftAnchor.constraint(equalTo: searchBarContainerView.leftAnchor, constant: searchBarEdgeInsets.left).isActive = true
        searchBarTextField!.rightAnchor.constraint(equalTo: searchBarContainerView.rightAnchor, constant: searchBarEdgeInsets.right).isActive = true
        searchBarTextField!.topAnchor.constraint(equalTo: searchBarContainerView.topAnchor, constant: searchBarEdgeInsets.top).isActive = true
        searchBarTextField!.bottomAnchor.constraint(equalTo: searchBarContainerView.bottomAnchor, constant: searchBarEdgeInsets.bottom).isActive = true
        searchBarTextField?.placeholder = query
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

