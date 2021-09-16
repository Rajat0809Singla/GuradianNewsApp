//
//  NewsListViewController.swift
//  GuradianNewsApp
//
//  Created by Rajat Singla on 15/09/21.
//

import UIKit

class NewsListViewController: UIViewController {
    @IBOutlet weak var newsListTableView: UITableView!
    private let refreshControl = UIRefreshControl()
    lazy var viewModel = NewsListViewModel()
    var selectedNews: NewsModel?
    
    // MARK: Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        newsListTableView.isHidden = true
        addRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initView()
    }

    // MARK: View Updation Methods
    private func initView() {
        viewModel.fetchNewsData { [weak self] (error) in
            guard let self = self else { return }
            self.updateTableView(error: error)
            self.newsListTableView.isHidden = false
        }
    }
    
    private func addRefreshControl() {
        if #available(iOS 10.0, *) {
            newsListTableView.refreshControl = refreshControl
        } else {
            newsListTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshNewsData(_:)), for: .valueChanged)
    }
    
    private func updateTableView(error: NetworkError?) {
        if error == nil {
            self.newsListTableView.reloadData()
        } else {
            switch error {
            case .badUrl:
                print("not data")
            case .noInternetError:
                self.showAlert("Alert", "Please enter city name")
            default:
                print("__")
            }
        }
    }
    
    @objc private func refreshNewsData(_ sender: Any) {
        viewModel.fetchNewsData(refresh: true) { error in
            self.updateTableView(error: error)
        }
        self.refreshControl.endRefreshing()
    }
    
    // MARK: Custom method for alert
    private func showAlert(_ title: String, _ msg: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Navigation Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationNavigationController = segue.destination as! NewsDetailViewController
        let newsDetailsViewModel = NewsDetailViewModel()
        newsDetailsViewModel.newsModel = selectedNews
        destinationNavigationController.viewModel = newsDetailsViewModel
    }
    
    
}


// MARK: Table View Methods
extension NewsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfCells()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsListTableViewCell.reuseIdentifier, for: indexPath) as? NewsListTableViewCell, let cellData = viewModel.getDataForCell(index: indexPath.row) else {
            return UITableViewCell()
        }
        cell.setDataOnCell(data: cellData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNews = viewModel.getDataForCell(index: indexPath.row)
        performSegue(withIdentifier: "NewsDetailSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row%9 == 0 && indexPath.row != 0 && viewModel.isAllNewsAreLoaded() {
            viewModel.fetchNextPage(completion: { [weak self] (error) in
                guard let self = self else { return }
                self.updateTableView(error: error)
            })
        }
    }
}
