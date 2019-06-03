//
//  FeedListViewController.swift
//  AppleNewsroom
//
//  Created by Akhil Waghmare on 6/3/19.
//  Copyright © 2019 Akhil Waghmare. All rights reserved.
//

import UIKit
import AWComponents
import FeedKit

class FeedItemCell: UICollectionViewCell {
    
    var feedEntry: AtomFeedEntry? {
        didSet {
            titleLabel.text = feedEntry?.title
        }
    }
    
    let imageView: CachedImageView = {
        let imageView = CachedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Item"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(imageView)
        addSubview(titleLabel)
        
        imageView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 0, widthConstant: 80, heightConstant: 0)
        titleLabel.anchor(topAnchor, left: imageView.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 20)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FeedListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let feedItemCellId = "feedItemCellId"
    
    var feedEntries: [AtomFeedEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        collectionView.register(FeedItemCell.self, forCellWithReuseIdentifier: feedItemCellId)
        
        fetchFeed()
    }
    
    private func fetchFeed() {
        guard let feedURL = URL(string: "https://www.apple.com/newsroom/rss-feed.rss") else { return }
        let parser = FeedParser(URL: feedURL)
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            guard let feed = result.atomFeed, result.isSuccess else {
                print(result.error)
                return
            }
            self.feedEntries = feed.entries ?? []
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedEntries.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedItemCellId, for: indexPath) as! FeedItemCell
        cell.feedEntry = feedEntries[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 100)
    }
}
