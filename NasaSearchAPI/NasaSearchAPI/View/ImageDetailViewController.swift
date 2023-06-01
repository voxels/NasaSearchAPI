//
//  ImageDetailViewController.swift
//  NasaSearchAPI
//
//  Created by Michael A Edgcumbe on 6/1/23.
//

import UIKit

final class ImageDetailViewController : UIViewController {
    internal var model:ImageDetailViewModel
    
    internal var imageView = UIImageView(frame:.zero)
    internal var titleLabel = UILabel(frame:.zero)
    internal var createdAtLabel = UILabel(frame:.zero)
    internal var descriptionTextView = UITextView(frame:.zero)
    
    public init(model: ImageDetailViewModel) {
        self.model = model
        super.init(nibName: nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        buildViews()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}


extension ImageDetailViewController {
    internal func buildViews() {
        
    }
}
