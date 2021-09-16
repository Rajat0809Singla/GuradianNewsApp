//
//  NewsListTableViewCell.swift
//  GuradianNewsApp
//
//  Created by Rajat Singla on 15/09/21.
//

import UIKit
import  WebKit

class NewsListTableViewCell: UITableViewCell {

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var thumbnailImageView: UIImageView!
    @IBOutlet weak var thumbnailWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var detailsWebView: WKWebView!
    
    func setDataOnCell(data: NewsModel) {
        titleLabel.text = data.webTitle
        thumbnailWidthConstraint.constant = data.fields?.thumbnail?.isEmpty ?? true ? 0: 100
        UIImageView.loadImage(from: data.fields?.thumbnail) { (image) in
            self.thumbnailImageView.image = image
        }
        timeLabel.text = data.webPublicationDate?.getDateStringForFormat(format: "E, d MMM yyyy h:mm:ss a")
        let headerString = "<head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head>"
        detailsWebView.loadHTMLString(headerString + (data.fields?.body ?? ""), baseURL: nil)
        
    }

}
