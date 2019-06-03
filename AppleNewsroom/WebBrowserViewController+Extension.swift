//
//  WebBrowserViewController+Extension.swift
//  AppleNewsroom
//
//  Created by Akhil Waghmare on 6/3/19.
//  Copyright © 2019 Akhil Waghmare. All rights reserved.
//

import KINWebBrowser

extension KINWebBrowserViewController: FeedEntrySelectionDelegate {
    func didSelectFeedUrl(_ url: String) {
        self.loadURLString(url)
    }
}
