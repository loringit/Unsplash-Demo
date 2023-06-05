//
//  ProfileViewController.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 05.06.2023.
//

import Combine
import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - Subviews
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.Background.primary
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(ProfileCountersCell.self, forCellReuseIdentifier: ProfileCountersCell.reuseIdentifier)
        tableView.register(ProfileHeaderCell.self, forCellReuseIdentifier: ProfileHeaderCell.reuseIdentifier)
        tableView.register(ProfileLinksCell.self, forCellReuseIdentifier: ProfileLinksCell.reuseIdentifier)
        
        return tableView
    }()
    
    // MARK: - Private properties
    
    private let viewModel: IProfileViewModel
    private var cells = [ProfileCellType]()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    init(viewModel: IProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .Background.primary
        
        setupLayout()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.reloadSubject.send()
    }
    
    // MARK: - Private methods
    
    private func setupLayout() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel
            .profilePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("\(#fileID) \(#line): \(error)")
                case .finished:
                    print("\(#fileID) \(#line): Finished")
                }
            }, receiveValue: { [weak self] cells in
                self?.cells = cells
                self?.tableView.reloadData()
            })
            .store(in: &subscriptions)
    }
    
}

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cells[indexPath.row] {
        case .counters(let counters):
            let _cell = tableView.dequeueReusableCell(withIdentifier: ProfileCountersCell.reuseIdentifier, for: indexPath)
            guard let cell = _cell as? ProfileCountersCell else { return UITableViewCell() }
            cell.model = counters
            return cell
        case .header(let header):
            let _cell = tableView.dequeueReusableCell(withIdentifier: ProfileHeaderCell.reuseIdentifier, for: indexPath)
            guard let cell = _cell as? ProfileHeaderCell else { return UITableViewCell() }
            cell.model = header
            return cell
        case .links(let links):
            let _cell = tableView.dequeueReusableCell(withIdentifier: ProfileLinksCell.reuseIdentifier, for: indexPath)
            guard let cell = _cell as? ProfileLinksCell else { return UITableViewCell() }
            cell.model = links
            cell.openURL = { [weak self] url in
                self?.viewModel.openUrlSubject.send(url)
            }
            return cell
        }
    }
    
}


extension ProfileViewController: UITableViewDelegate {
    
    
    
}
