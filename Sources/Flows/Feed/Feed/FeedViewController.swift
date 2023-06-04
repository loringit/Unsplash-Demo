//
//  FeedViewController.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 03.06.2023.
//

import Combine
import UIKit

class FeedViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = UIColor.Background.primary
        searchBar.tintColor = UIColor.Text.primary
        searchBar.searchTextField.tintColor = UIColor.Text.primary
        searchBar.searchTextField.textColor = UIColor.Text.primary
        searchBar.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18)
        return searchBar
    }()
    
    private lazy var layout: PinterestLayout = {
        let layout = PinterestLayout()
        layout.delegate = self
        return layout
    }()
    private lazy var collectionView: UICollectionView = {

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.Background.primary
        collectionView.contentInset = .init(top: 18, left: 18, bottom: 0, right: 18)
        
        view.addSubview(collectionView)

        return collectionView
    }()
    
    // MARK: - Private properties
    
    private lazy var datasource: UICollectionViewDiffableDataSource<Int, FeedItem> = {
        let itemCellRegistration = UICollectionView.CellRegistration<FeedCell, FeedItem> { (cell, indexPath, cellItem) in
            cell.setup(with: cellItem)
        }
        
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, cellItem in
            return collectionView.dequeueConfiguredReusableCell(using: itemCellRegistration, for: indexPath, item: cellItem)
        }
    }()
    private let viewModel: IFeedViewModel
    private var subscriptions = Set<AnyCancellable>()
    private var bottomConstraint: NSLayoutConstraint?
    private var items = [FeedItem]()
    
    // MARK: - Lifecycle
    
    init(viewModel: IFeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.Background.primary
        
        setupLayout()
        setupKeyboardListeners()
        setupBindings()
//        loadNext()
    }
        
    private func setupLayout() {
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        
        bottomConstraint = collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint!
        ])
    }
    
    private func setupKeyboardListeners() {
        NotificationCenter
            .default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .sink(receiveValue: { [weak self] notification in
                let frameEndKey = UIResponder.keyboardFrameEndUserInfoKey
                let animationDurationKey = UIResponder.keyboardAnimationDurationUserInfoKey
                
                guard
                    let self,
                    let userInfo = notification.userInfo,
                    let keyboardFrame = (userInfo[frameEndKey] as? NSValue)?.cgRectValue,
                    let duration: TimeInterval = (userInfo[animationDurationKey] as? NSNumber)?.doubleValue
                else {
                    return
                }
                
                self.bottomConstraint?.constant = -keyboardFrame.height + self.view.safeAreaInsets.bottom + (self.tabBarController?.tabBar.frame.height ?? 0)
                self.animateLayoutIfNeeded(duration)
            })
            .store(in: &subscriptions)
        
        NotificationCenter
            .default
            .publisher(for:UIResponder.keyboardWillHideNotification)
            .sink(receiveValue: { [weak self] notification in
                let animationDurationKey = UIResponder.keyboardAnimationDurationUserInfoKey
                
                guard
                    let userInfo = notification.userInfo,
                    let duration: TimeInterval = (userInfo[animationDurationKey] as? NSNumber)?.doubleValue
                else {
                    return
                }
                
                self?.bottomConstraint?.constant = 0
                self?.animateLayoutIfNeeded(duration)
            })
            .store(in: &subscriptions)
    }
    
    private func animateLayoutIfNeeded(_ duration: CGFloat) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: duration,
            delay: 0,
            options: [],
            animations: { [weak self] in
                self?.view.layoutIfNeeded()
            }
        )
    }
    
    private func setupBindings() {
        viewModel
            .photosPublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] items in
                    guard let self else { return }
                    
                    self.items = items
                    
                    var snapshot = NSDiffableDataSourceSnapshot<Int, FeedItem>()
                    snapshot.appendSections([0])
                    snapshot.appendItems(items, toSection: 0)
                    self.datasource.apply(snapshot, animatingDifferences: true)
                }
            )
            .store(in: &subscriptions)
        
        viewModel
            .refreshLayoutPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.layout.clearCache()
            }
            .store(in: &subscriptions)
    }
    
    private func loadNext() {
        viewModel.nextPageSubject.send(())
    }
    
}

extension FeedViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.querySubject.send(searchText)
        viewModel.nextPageSubject.send(())
    }
    
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
      return CGSize(width: itemSize, height: itemSize)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let expectedOffset = targetContentOffset.pointee.y
        let contentSize = scrollView.contentSize.height
        let contentPageSize = scrollView.frame.height
        let bottomOffset = expectedOffset + contentPageSize
        let pagesRest = (contentSize - bottomOffset) / contentPageSize
        if pagesRest < 2 {
            loadNext()
        }
    }
    
}

extension FeedViewController: PinterestLayoutDelegate {
    
    func numberOfItems() -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, ratioForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < items.count else {
            return 0
        }
        return items[indexPath.row].ratio
    }
    
}
