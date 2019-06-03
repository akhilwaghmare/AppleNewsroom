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
import KINWebBrowser

class FeedItemCell: UICollectionViewCell {
    
    var feedEntry: AtomFeedEntry? {
        didSet {
            titleLabel.text = feedEntry?.title
            tagLabel.text = feedEntry?.categories?.first?.attributes?.term?.uppercased()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            dateLabel.text = dateFormatter.string(from: feedEntry?.updated ?? Date())
            
            if let imageLink = feedEntry?.links?.first(where: { (link) -> Bool in
                return link.attributes?.type == "image/jpeg"
            })?.attributes?.href {
                imageView.loadImage(urlString: imageLink)
            }
        }
    }
    
    let imageView: CachedImageView = {
        let imageView = CachedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    let tagLabel: UILabel = {
        let label = UILabel()
        label.text = "Tag".uppercased()
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Item"
        label.numberOfLines = 3
        return label
    }()
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(imageView)
        addSubview(tagLabel)
        addSubview(titleLabel)
        addSubview(dateLabel)
        
        imageView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 0, widthConstant: 80, heightConstant: 0)
        tagLabel.anchor(topAnchor, left: imageView.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 10)
        titleLabel.anchor(tagLabel.bottomAnchor, left: imageView.rightAnchor, bottom: dateLabel.topAnchor, right: rightAnchor, topConstant: 4, leftConstant: 8, bottomConstant: 4, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        dateLabel.anchor(nil, left: titleLabel.leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 8, rightConstant: 8, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol FeedEntrySelectionDelegate {
    func didSelectFeedUrl(_ url: String)
}

class FeedListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let feedItemCellId = "feedItemCellId"
    
    var feedEntries: [AtomFeedEntry] = []
    var delegate: FeedEntrySelectionDelegate?
    
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
        return CGSize(width: collectionView.bounds.width, height: 120)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = self.delegate else { return }
        guard let entryUrl = feedEntries[indexPath.item].links?.first?.attributes?.href else { return }
        delegate.didSelectFeedUrl(entryUrl)
        
        if let detailVC = delegate as? KINWebBrowserViewController {
            splitViewController?.showDetailViewController(detailVC, sender: nil)
        }
    }
}
