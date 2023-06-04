//
//  InfoViewController.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 05.06.2023.
//

import UIKit

class InfoViewController: UIViewController {
    
    fileprivate enum CellType {
        
        case description(String)
        case property((String, String))
        
    }
    
    // MARK: - Subviews
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.Background.primary
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(InfoDescriptionCell.self, forCellReuseIdentifier: InfoDescriptionCell.reuseIdentifier)
        tableView.register(InfoPropertyCell.self, forCellReuseIdentifier: InfoPropertyCell.reuseIdentifier)
        
        return tableView
    }()
    
    // MARK: - Private properties
    
    private let item: PhotoItem
    private var cells = [CellType]()
    
    // MARK: - Lifecycle
    
    init(item: PhotoItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .Background.primary
        
        setupLayout()
        populateData()
        tableView.reloadData()
    }
    
    // MARK: - Private methods
    
    private func setupLayout() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func populateData() {
        if let description = item.description {
            cells.append(.description(description))
        } else if let altDescription = item.altDescription {
            cells.append(.description(altDescription))
        }
        
        guard let properties = item.properties else { return }
        
        for (property, value) in properties {
            cells.append(.property((property, value)))
        }
    }
    
}

extension InfoViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cells.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cells[indexPath.row] {
        case .description(let description):
            let _cell = tableView.dequeueReusableCell(withIdentifier: InfoDescriptionCell.reuseIdentifier, for: indexPath)
            guard let cell = _cell as? InfoDescriptionCell else { return UITableViewCell() }
            cell.text = description
            return cell
        case .property(let property):
            let _cell = tableView.dequeueReusableCell(withIdentifier: InfoPropertyCell.reuseIdentifier, for: indexPath)
            guard let cell = _cell as? InfoPropertyCell else { return UITableViewCell() }
            cell.property = property.0
            cell.value = property.1
            return cell
        }
    }
    
}

extension InfoViewController: UITableViewDelegate {
    
}
