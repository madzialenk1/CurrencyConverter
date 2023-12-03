//
//  SearchBarViewController.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 29/11/2023.
//

import Foundation
import SnapKit
import RxSwift

class SearchViewController: UIViewController {
    private let sendingToLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "sending_to_label".localized()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let searchBar: CustomSearchBar = {
        let searchBar = CustomSearchBar()
        return searchBar
    }()
    
    private let allCountriesLabel: UILabel = {
        let label = UILabel()
        label.text = "all_countries_label".localized()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CountryTableViewCell.self, forCellReuseIdentifier: "CountryCell")
        tableView.rowHeight = 60
        return tableView
    }()
    
    private let noResultView = NoResultView()
    
    private let disposedBag = DisposeBag()
    private let viewModel: CurrencyConverterViewModel
    
    init(viewModel: CurrencyConverterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        setRx()
        setConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(sendingToLabel)
        view.addSubview(searchBar)
        view.addSubview(allCountriesLabel)
        view.addSubview(tableView)
    }
    
    private func setConstraints() {
        sendingToLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.trailing.equalToSuperview().offset(16)
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(sendingToLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        allCountriesLabel.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(allCountriesLabel.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setRx() {
        viewModel.selectionSource
            .bind {[weak self] selection in
                self?.sendingToLabel.text = selection == .from ? "sending_from_label".localized() : "sending_to_label".localized()
            }.disposed(by: disposedBag)
        
        viewModel.filteredCountries
            .do(onNext: { [weak self] countries in
                if countries.isEmpty {
                    guard let view = self?.noResultView else { return }
                    self?.tableView.backgroundView = view
                } else {
                    self?.tableView.backgroundView = nil
                }
            })
            .bind(to: tableView.rx.items(cellIdentifier: "CountryCell", cellType: CountryTableViewCell.self)) { (_, country, cell) in
                cell.configure(with: country)
            }
            .disposed(by: disposedBag)
        
        searchBar.searchTextField.rx.text
            .orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind { [weak self] searchText in
                self?.viewModel.filterCountries(by: searchText)
            }
            .disposed(by: disposedBag)
        
        Observable.combineLatest(tableView.rx.modelSelected(Country.self), viewModel.selectionSource)
            .subscribe(onNext: { [weak self] country, selection in
                if let indexPath = self?.tableView.indexPathForSelectedRow {
                    self?.tableView.deselectRow(at: indexPath, animated: true)
                }
                selection == .from ? self?.viewModel.selectedCurrencyFrom.accept(country) : self?.viewModel.selectedCurrencyTo.accept(country)
                self?.dismiss(animated: true)
                
            })
            .disposed(by: disposedBag)
    }
}
