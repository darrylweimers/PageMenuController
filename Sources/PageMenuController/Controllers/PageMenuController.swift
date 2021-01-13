//
//  ViewController.swift
//  PageMenuControllerBase
//
//  Created by Darryl Weimers on 2020-12-20.
//

import UIKit
import UtilityKit

@available(iOS 13.0, *)
public protocol PageMenuDelegate {
    func pageMenu(didChangeToPageAtIndex index: Int)
}

@available(iOS 13.0, *)
public class PageMenuController: UIViewController, MenuViewDataSource, MenuViewDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate {
    
    // MARK: store properties
    public var startAtPageIndex: Int
    public var delegate: PageMenuDelegate?
    
    private var pageControllers : [UIViewController]
    private var menuTitles: [String]
    private let numberOfVisibleMenuItem = 3
    private var higlightedMenuItemIndex: Int?
    private var nextPageIndex: Int?
    private var currentPageIndex: Int?
    
    // MARK: computed
    private var menuTitlesWithSpacer: [String] {
        get {
            return [""] + menuTitles + [""]
        }
    }
    
    private lazy var menuController: MenuController = {
        let controller = MenuController()
        controller.datasource = self
        controller.delegate = self
        controller.view.backgroundColor = .white
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()
    
    public lazy var pageViewController: UIPageViewController = {
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        controller.delegate = self
        controller.dataSource = self
        controller.view.backgroundColor = .white
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()
    
    // MARK: init
    public init?(menuTitles: [String], pageControllers: [UIViewController], startAtPageIndex: Int = 0) {
        self.menuTitles = menuTitles
        self.pageControllers = pageControllers
        guard menuTitles.count == pageControllers.count,
              menuTitles.count > 0,
              pageControllers.count > 0,
              startAtPageIndex < pageControllers.count,
              startAtPageIndex >= 0 else {
            return nil
        }
        self.currentPageIndex = startAtPageIndex
        self.startAtPageIndex = startAtPageIndex
        super.init(nibName: nil, bundle: nil)
    }
      
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: page view controller delegate and datasource
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {

        guard let nextPageController = pendingViewControllers.first else {
            return
        }
        nextPageIndex = pageControllers.firstIndex(of: nextPageController)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if (completed) {
            currentPageIndex = nextPageIndex
            
            if let pageIndex = currentPageIndex {
                let menuIndex = convertToMenuIndex(pageIndex: pageIndex)
                setHighlightedMenuCell(at: menuIndex)
                menuController.selectMenuItem(at: menuIndex)
                delegate?.pageMenu(didChangeToPageAtIndex: pageIndex)
            }
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pageControllers.firstIndex(of: viewController),
                index - 1 >= 0 else {
            return nil // no page
        }
        
        return pageControllers[index - 1] // previous page controller
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let index = pageControllers.firstIndex(of: viewController),
                index + 1 < pageControllers.count else {
            return nil // no page
        }

        return pageControllers[index + 1] // next page controller
    }


    // MARK: menu view data and delegate
    public func menuView(_ menuView: UICollectionView, didSelectItemAt index: Int) {
        // index did change?
        guard let previousIndex = higlightedMenuItemIndex else {
            return
        }
        
        let indexMoved = index - previousIndex // positive value: forward, negative value: backwards; zero: no change
        guard indexMoved != 0,
              let pageIndex = convertToPageIndex(menuIndex: index) else {
            return
        }
        
        // scroll to page
        self.pageViewController.setViewControllers([pageControllers[pageIndex]], direction: indexMoved > 0 ? .forward : .reverse, animated: true, completion: nil)
        
        // scroll to menu item
        setHighlightedMenuCell(at: index)
        menuController.selectMenuItem(at: index)
        delegate?.pageMenu(didChangeToPageAtIndex: pageIndex)
    }
    
    public func menuViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let previousIndex = higlightedMenuItemIndex else {
            return
        }
        
        guard let index = menuController.getCenterItemIndex() else {
            return
        }
    
        let indexMoved = index - previousIndex // positive value: forward, negative value: backwards; zero: no change
        guard indexMoved != 0,
              let pageIndex = convertToPageIndex(menuIndex: index) else {
            return
        }
        
        setHighlightedMenuCell(at: index)
        
        self.pageViewController.setViewControllers([pageControllers[pageIndex]], direction: indexMoved > 0 ? .forward : .reverse, animated: true, completion: nil)
        delegate?.pageMenu(didChangeToPageAtIndex: pageIndex)
        
    }
    
    // MARK: index conversion
    private func convertToMenuIndex(pageIndex index: Int) -> Int {
        return index + 1 // menu item is prepended to a spacer
    }
    
    private func convertToPageIndex(menuIndex index: Int) -> Int? {
        let pageIndex = index - 1 // menu item is prepended and appended with a spacer item
        guard pageIndex >= 0,
              pageIndex < pageControllers.count else {
            return nil
        }
        return pageIndex
    }
    
    // MARK:  highlight menu item controls
    private func setHighlightedMenuCell(at index: Int) {
        higlightedMenuItemIndex = index
        menuController.collectionView.reloadData()
    }
    
    // MARK: menu data source and delegate
    public func numberOfItems(in menuView: UICollectionView) -> Int {
        return menuTitlesWithSpacer.count
    }
    
    public func numberOfVisibleItem(in menuView: UICollectionView) -> Int {
        return numberOfVisibleMenuItem
    }
    
    public func menuView(_ menuView: UICollectionView, itemAt index: Int) -> LabelCell {
        guard let cell = menuView.dequeueReusableCell(withReuseIdentifier: LabelCell.reuseIdentifier, for: IndexPath(row: index, section: 0)) as? LabelCell else {
            fatalError("Fail to dequeue cell")
        }
        
        cell.label.font = UIFont.preferredFont(forTextStyle: .headline)
        cell.label.text = menuTitlesWithSpacer[index]
        cell.label.textColor = .secondaryLabel
        guard let menuIndex = higlightedMenuItemIndex,
              menuIndex == index else {
            return cell
        }
        
        cell.label.textColor = .black
        return cell
    }
    
    
    // MARK: view setups
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let controllers: [UIViewController] = [menuController, pageViewController]
        controllers.forEach { (controller) in
            add(controller)
        }
        
        setupViews()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setHighlightedMenuCell(at: convertToMenuIndex(pageIndex: startAtPageIndex))
        
        let startingPageController = pageControllers[startAtPageIndex]
        pageViewController.setViewControllers([startingPageController], direction: .forward, animated: true, completion: nil)
        delegate?.pageMenu(didChangeToPageAtIndex: startAtPageIndex)
    }
    
    private func setupViews() {
        let superview: UIView = self.view
        self.view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            menuController.view.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
            menuController.view.heightAnchor.constraint(equalToConstant: 60.0),
            menuController.view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            menuController.view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),

        ])
        
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: menuController.view.bottomAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),

        ])
        
    }
    
    public func scrollToPage(atIndex desiredPageIndex: Int) {
        guard desiredPageIndex < pageControllers.count,
              desiredPageIndex >= 0,
              let _currentPageIndex = currentPageIndex,
              _currentPageIndex != desiredPageIndex else {
            return
        }
       
        
        self.pageViewController.setViewControllers([pageControllers[desiredPageIndex]], direction: desiredPageIndex > _currentPageIndex ? .forward : .reverse, animated: true, completion: nil)
        
        let desiredMenuIndex = convertToMenuIndex(pageIndex: desiredPageIndex)
        
        // scroll to menu item
        setHighlightedMenuCell(at: desiredMenuIndex)
        menuController.selectMenuItem(at: desiredMenuIndex)
    }

}

