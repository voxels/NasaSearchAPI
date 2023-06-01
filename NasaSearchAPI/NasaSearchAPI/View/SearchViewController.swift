//
//  SearchViewController.swift
//  NasaSearchAPI
//
//  Created by Michael A Edgcumbe on 6/1/23.
//

import UIKit

public class SearchViewController: UIViewController {
    internal var model:SearchViewModel
    internal var collectionView: UICollectionView! = nil
    internal var searchBarContainerView:UIView = UIView(frame:.zero)
    internal var searchBarTextField:UISearchTextField?

    private let searchBarContainerViewHeight:CGFloat = 48 + 16
    private let searchBarEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: -8, right: -20)

    internal var dataSource: UICollectionViewDiffableDataSource<Section, NASASearchCollectionItem>! = nil
    
    public enum Section {
        case main
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let defaults = UserDefaults.standard
        if let lastQuery = defaults.string(forKey: SearchViewModel.lastQueryDefaultsKey) {
            model = SearchViewModel(currentQuery:lastQuery)
        } else {
            model = SearchViewModel()
        }
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        model.delegate = self
        buildSearchBarContainerView(with: model.currentQuery)
        buildSearchQueryResponseCollectionView()
        updateModel(with: model.currentQuery)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = "NASA Images"
        navigationController?.setNavigationBarHidden(false, animated: true)
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
    
    internal func buildSearchQueryResponseCollectionView() {
        configureHierarchy()
        configureDataSource()
    }
}

extension SearchViewController {
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
              
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(view.frame.size.width))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
      
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 8.0
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints  = false
        view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.systemBackground
        collectionView.topAnchor.constraint(equalTo: searchBarContainerView.bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<SearchQueryResponseCollectionViewCell, NASASearchCollectionItem> { (cell, indexPath, item) in
            cell.searchCollectionItem = item
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, NASASearchCollectionItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: NASASearchCollectionItem) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
    }
    
    private func updateCollectionViewModel(with items:[NASASearchCollectionItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, NASASearchCollectionItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension SearchViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? SearchQueryResponseCollectionViewCell, let item = cell.searchCollectionItem {
            let detailModel = ImageDetailViewModel(item: item)
            let detailViewController = ImageDetailViewController(model: detailModel)
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        guard numberOfItems >= 1 else {
            return
        }
        
        let triggerItem = numberOfItems - 1
        
        if indexPath.item >= triggerItem, model.lastPage < 100 {
            updateModel(with: model.currentQuery, on: model.lastPage + 1)
        }
    }
}


extension SearchViewController : SearchViewModelDelegate {
    public func modelDidUpdateQuery() {
        searchBarTextField?.placeholder = model.currentQuery
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
    }
    
    public func modelDidUpdate(with response: NASASearchResponse) {
        model.add(collection: response.collection)
        var allItems = [NASASearchCollectionItem]()
        for collection in model.allCollections {
            allItems.append(contentsOf: collection.items)
        }
        updateCollectionViewModel(with: allItems)
    }
}

