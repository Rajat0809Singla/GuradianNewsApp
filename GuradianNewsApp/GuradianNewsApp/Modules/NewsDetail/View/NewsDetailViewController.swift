//
//  NewsDetailViewController.swift
//  GuradianNewsApp
//
//  Created by Rajat Singla on 15/09/21.
//

import UIKit
import WebKit

class NewsDetailViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: NSLayoutConstraint!
    
    // MARK: Data
    lazy var viewModel = NewsDetailViewModel()

    // MARK: Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDataOnView()
    }
    
    // MARK: View Updation Methods
    private func setDataOnView() {
        titleLabel.text = viewModel.getWebTitile()
        let thumbnailUrl  = viewModel.getThumbnailUrl()
        thumbnailImageView.constant = thumbnailUrl.isEmpty ? 0: 200
        UIImageView.loadImage(from: thumbnailUrl) { (image) in
            self.newsImageView.image = image
        }
        timeLabel.text = viewModel.getNewsDate()
        detailsLabel.attributedText = viewModel.getBody()
    }
    
    // MARK: Action Methods
    @IBAction func openInSafariButtonTapped(_ sender: Any) {
        guard let url = URL(string: viewModel.getWebUrl()) else { return }
        UIApplication.shared.open(url)
    }
}

