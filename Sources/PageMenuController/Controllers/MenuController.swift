//
//  MenuController.swift
//  PageMenuControllerBase
//
//  Created by Darryl Weimers on 2020-12-20.
//

import UIKit

@available(iOS 13.0, *)
public protocol MenuViewDataSource {
    func numberOfItems(in menuView: UICollectionView) -> Int
    func numberOfVisibleItem(in menuView: UICollectionView) -> Int
    func menuView(_ menuView: UICollectionView, itemAt index: Int) -> LabelCell
}

@available(iOS 13.0, *)
public protocol MenuViewDelegate {
    func menuViewDidEndDecelerating(_ scrollView: UIScrollView)
    func menuView(_ menuView: UICollectionView, didSelectItemAt index: Int)
}

@available(iOS 13.0, *)
public class MenuController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: Delegate
    public var datasource: MenuViewDataSource?
    public var delegate: MenuViewDelegate?

    // MARK: UI componenents
    public lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: SnappingCollectionViewFlowLayout())
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // delegates
        collectionView.dataSource = self
        collectionView.delegate = self
        // cells
        collectionView.register(LabelCell.self, forCellWithReuseIdentifier: LabelCell.reuseIdentifier)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        return collectionView
    }()

    private func setupViews() {
        let superview: UIView = self.view
        superview.backgroundColor = .white

        // add subviews
        [collectionView].forEach( {superview.addSubview($0)} )

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
        ])

    }

    // MARK: collection view data source
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource?.numberOfItems(in: collectionView) ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return datasource?.menuView(collectionView, itemAt: indexPath.row) ?? UICollectionViewCell()
    }

    // MARK: collection view delegate flow
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let superview: UIView = self.view
        let width = superview.bounds.width / CGFloat(datasource?.numberOfVisibleItem(in: collectionView) ?? 1)
        let height = superview.bounds.height
        return CGSize(width: width, height: height)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - collection view delegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.menuView(collectionView, didSelectItemAt: indexPath.row)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.menuViewDidEndDecelerating(scrollView)
    }
    
    public func getCenterItemIndex() -> Int? {
        let center = self.view.convert(collectionView.center, to: collectionView)
        let indexPath = collectionView.indexPathForItem(at: center)
        return indexPath?.row
    }

    // MARK: select menu item
    public func selectMenuItem(at index: Int) { 
        collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }

}
