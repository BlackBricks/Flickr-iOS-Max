//
//  TableViewCell.swift
//  Flickr
//
//  Created by metoSimka on 12/03/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit

class RecentTableViewCell: UITableViewCell {
    
    var dataRecentSearches = [String]()
    weak var delegate: recentTableCellDelegate?
    @IBOutlet weak var recentText: UILabel!
    @IBAction func clearButton(_ sender: UIButton) {
        delegate?.didTapClearButton(self)
    }
    
    func loadDataTable(_ array: [String],_ index: Int) {
        recentText.text = array[index]
    }
}

protocol recentTableCellDelegate : class {
    func didTapClearButton(_ sender: RecentTableViewCell)
}

