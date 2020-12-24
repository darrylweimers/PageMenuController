//
//  LabelCell.swift
//  PasteBoard
//
//  Created by Darryl Weimers on 2020-08-30.
//  Copyright © 2020 Darryl Weimers. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
public class LabelCell: UICollectionViewCell {
    
    public static let reuseIdentifier = "\(LabelCell.self)"
    
    private var _tintColor: UIColor = .secondaryLabel
    public override var tintColor: UIColor! {
        get {
            return _tintColor
        }
        set (color) {
            _tintColor = color
            label.textColor = color // TODO: maybe consider using highlighted color and is higlighted
        }
    }
    
    public lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Title"
        label.textAlignment = .center
        label.textColor = _tintColor
        label.backgroundColor = .clear
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // for creating views
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let superview: UIView = self.contentView
        
        // centered label
        layoutViews(superview: superview)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // for reseting views
    public override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    public func reset() {
        self.label.textAlignment = .center
    }
    
    private func layoutViews(superview: UIView) {
        superview.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: superview.topAnchor),
            label.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
        ])
    }
}
