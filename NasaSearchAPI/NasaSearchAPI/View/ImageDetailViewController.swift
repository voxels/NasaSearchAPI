//
//  ImageDetailViewController.swift
//  NasaSearchAPI
//
//  Created by Michael A Edgcumbe on 6/1/23.
//

import UIKit

final class ImageDetailViewController : UIViewController {
    internal var model:ImageDetailViewModel
    
    internal var scrollView = UIScrollView(frame:.zero)
    internal var imageView = UIImageView(frame:.zero)
    internal var titleLabel = UILabel(frame:.zero)
    internal var createdAtLabel = UILabel(frame:.zero)
    internal var descriptionTextView = UITextView(frame:.zero)
    internal let labelEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right:-20)
    internal let labelFontSize:CGFloat = 14.0
    internal let descriptionFontSize:CGFloat = 12.0
    internal let textColor = UIColor.label
    
    internal var imageTask:Task<UIImage?, Error>?
    internal let imageURLSession = URLSession(configuration: URLSessionConfiguration.default)
    internal var previewImageRelString = "preview"
    
    internal var imageViewHeightConstraint:NSLayoutConstraint?
    internal var titleLabelHeightConstraint:NSLayoutConstraint?
    internal var descriptionTextViewHeightConstraint:NSLayoutConstraint?
    
    
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
        apply(model: model)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = ""
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageTask?.cancel()
    }
}


extension ImageDetailViewController {
    internal func buildViews() {
        buildScrollView()
        buildImageView()
        buildTitleLabel()
        buildCreatedAtLabel()
        buildDescriptionTextView()
    }
    
    internal func buildScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    internal func buildImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)
        imageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        imageView.contentMode = .scaleAspectFit
    }
    
    internal func buildTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: labelEdgeInsets.left).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: labelEdgeInsets.right).isActive = true
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: labelEdgeInsets.top).isActive = true
        titleLabel.numberOfLines = 0
    }
    
    internal func buildCreatedAtLabel() {
        createdAtLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(createdAtLabel)
        createdAtLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: labelEdgeInsets.left).isActive = true
        createdAtLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant:labelEdgeInsets.right).isActive = true
        createdAtLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: labelEdgeInsets.top).isActive = true
        createdAtLabel.numberOfLines = 1
    }
    
    internal func buildDescriptionTextView() {
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(descriptionTextView)
        descriptionTextView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: labelEdgeInsets.left).isActive = true
        descriptionTextView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: labelEdgeInsets.right).isActive = true
        descriptionTextView.topAnchor.constraint(equalTo: createdAtLabel.bottomAnchor, constant: labelEdgeInsets.top).isActive = true
        descriptionTextView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: labelEdgeInsets.bottom).isActive = true
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.isEditable = false
    }
}

extension ImageDetailViewController {
    internal func apply(model:ImageDetailViewModel) {
        guard let data = model.item.data.first else {
            return
        }
        
        let titleAttributedString = NSAttributedString(string: data.title, attributes: [.foregroundColor:textColor, .font:UIFont.boldSystemFont(ofSize: labelFontSize)])
        titleLabel.attributedText = titleAttributedString
        let titleLabelSize = titleLabel.sizeThatFits(CGSize(width: view.frame.size.width - labelEdgeInsets.left + labelEdgeInsets.right, height:CGFloat.greatestFiniteMagnitude))
        titleLabelHeightConstraint = NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant:titleLabelSize.height )
        titleLabelHeightConstraint?.isActive = true
        
        
        if let date = decodedDate(from: data.dateCreated) {
            let createdAtAttributedString = NSAttributedString(string: dateString(from: date), attributes: [.foregroundColor:textColor, .font:UIFont.systemFont(ofSize: labelFontSize)])
            createdAtLabel.attributedText = createdAtAttributedString
            createdAtLabel.sizeToFit()
        }
        
        let descriptionAttributedString = NSAttributedString(string: data.description, attributes: [.foregroundColor:textColor, .font:UIFont.systemFont(ofSize: descriptionFontSize)])
        descriptionTextView.attributedText = descriptionAttributedString
        let descriptionTextViewSize = descriptionTextView.sizeThatFits(CGSize(width: view.frame.size.width - labelEdgeInsets.left + labelEdgeInsets.right, height: CGFloat.greatestFiniteMagnitude))
        descriptionTextViewHeightConstraint = NSLayoutConstraint(item: descriptionTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: descriptionTextViewSize.height)
        descriptionTextViewHeightConstraint?.isActive = true
        
        for link in model.item.links {
            if link.rel == previewImageRelString {
                let _ = Task.init {
                    do {
                        try await updateImageView(with: link.href)
                    } catch {
                        //report error to logging
                        print(error)
                    }
                }
                break
            }
        }
    }
    
    internal func updateImageView(with imageUrlString:String) async throws {
        guard let url = URL(string: imageUrlString) else {
            throw SearchQueryResponseCollectionViewCellError.URLEncodingError
        }
        
        imageTask = Task.init {
            do {
                let data = try await imageURLSession.data(for: URLRequest(url: url))
                return UIImage(data: data.0)
            } catch {
                //report error to logging
                print(error)
                return nil
            }
        }
        
        guard let image = try await imageTask?.value else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let aspectRatio = image.size.width / image.size.height
            strongSelf.imageViewHeightConstraint = NSLayoutConstraint(item: strongSelf.imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: strongSelf.view.frame.size.width / aspectRatio)
            strongSelf.imageViewHeightConstraint?.isActive = true
            strongSelf.imageView.image = image
        }
    }

}

extension ImageDetailViewController {
    internal func decodedDate(from encodedDate:String)->Date? {
        return ImageDetailViewModel.iso8601Formatter.date(from: encodedDate)
    }
    
    internal func dateString(from date:Date)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}
