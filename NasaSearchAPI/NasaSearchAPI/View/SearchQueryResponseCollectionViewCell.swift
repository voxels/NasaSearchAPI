//
//  SearchQueryResponseCollectionViewCell.swift
//  NasaSearchAPI
//
//  Created by Michael A Edgcumbe on 6/1/23.
//

import UIKit

public enum SearchQueryResponseCollectionViewCellError : Error {
    case URLEncodingError
}

open class SearchQueryResponseCollectionViewCell : UICollectionViewCell {
    public var searchCollectionItem:NASASearchCollectionItem? {
        didSet {
            if let response = searchCollectionItem {
                updateView(with: response)
            }
        }
    }
    
    internal var textLabel:UILabel = UILabel(frame:.zero)
    internal var textLabelEdgeInsets = UIEdgeInsets(top: 0, left: 8.0, bottom: -8, right: -8.0)
    internal let textLabelAttributes:[NSAttributedString.Key:Any] = [.foregroundColor : UIColor.label, .font:UIFont.systemFont(ofSize: 14.0)]
    internal var textLabelHeightConstraint:NSLayoutConstraint?
    internal var scrimViewHeightConstraint:NSLayoutConstraint?
    internal var imageView = UIImageView(frame:.zero)
    internal var previewImageRelString = "preview"
    internal let scrimView = UIView(frame:.zero)
    internal let scrimViewGradientLayer = CAGradientLayer()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        buildViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        textLabel.text = ""
        
        if let heightConstraint = textLabelHeightConstraint {
            heightConstraint.isActive = false
        }
        
        if let heightConstraint = scrimViewHeightConstraint {
            heightConstraint.isActive = false
        }
    }
    
}

extension SearchQueryResponseCollectionViewCell {
    internal func buildViews() {
        contentView.backgroundColor = UIColor.systemBackground
        buildImageView()
        buildTextView()
        buildScrimView()
    }

    
    internal func buildImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor.systemBlue
        contentView.addSubview(imageView)
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
        
    internal func buildTextView() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)
        textLabel.numberOfLines = 0
        textLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: textLabelEdgeInsets.left).isActive = true
        textLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: textLabelEdgeInsets.right).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: textLabelEdgeInsets.bottom).isActive = true
        textLabel.textColor = UIColor.white
    }
    
    internal func buildScrimView() {
        scrimView.translatesAutoresizingMaskIntoConstraints = false
        contentView.insertSubview(scrimView, belowSubview: textLabel)
        scrimView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        scrimView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        scrimView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        let bottomColor = UIColor.systemBackground.withAlphaComponent(0.8)
        scrimViewGradientLayer.colors = [UIColor.clear.cgColor, bottomColor.cgColor]
        scrimView.layer.addSublayer(scrimViewGradientLayer)
    }
}

extension SearchQueryResponseCollectionViewCell {
    internal func updateView(with response:NASASearchCollectionItem) {
        if let textLabelHeightConstraint = textLabelHeightConstraint, textLabelHeightConstraint.isActive {
            textLabelHeightConstraint.isActive = false
        }
        
        if let title = response.data.first?.title {
            updateTextView(with: title)
        }
        
        for link in response.links {
            if link.rel == previewImageRelString {
                let imageUrlString = link.href
                    let _ = Task.init {
                        do {
                            try await updateImageView(with: imageUrlString)
                        }
                        catch {
                            //report error to logging
                            print(error)
                        }
                }
                break
            }
        }
    }
    
    internal func updateTextView(with title:String) {
        let attributedString = NSAttributedString(string: title, attributes: textLabelAttributes)
        textLabel.attributedText = attributedString
        let size = textLabel.sizeThatFits(CGSize(width: contentView.frame.size.width - textLabelEdgeInsets.left + textLabelEdgeInsets.right, height: CGFloat.greatestFiniteMagnitude))
        textLabelHeightConstraint = NSLayoutConstraint(item: textLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: size.height)
        textLabelHeightConstraint?.isActive = true
        
        guard let heightConstraint = textLabelHeightConstraint else {
            return
        }
        
        scrimViewHeightConstraint = NSLayoutConstraint(item: scrimView, attribute: .height, relatedBy: .equal, toItem:nil, attribute: .notAnAttribute, multiplier: 1.0, constant: heightConstraint.constant * 10)
        scrimViewHeightConstraint?.isActive = true
        scrimViewGradientLayer.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: scrimViewHeightConstraint!.constant)
    }
    
    internal func updateImageView(with imageUrlString:String) async throws {
        guard let url = URL(string: imageUrlString) else {
            throw SearchQueryResponseCollectionViewCellError.URLEncodingError
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    self?.imageView.image = UIImage(data: data)
                }
            } catch {
                //report error to logging
                print(error)
            }
        }
    }
}
