//
//  ViewController.swift
//  Kadai16-MVVM
//
//  Created by 今村京平 on 2021/07/16.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var itemTableView: UITableView!
    private let itemViewModel = ItemViewModel()
    private var disposeBag = Set<NSKeyValueObservation>() // KVO使用
    private var items: [Item] = []

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView()
        setupBindings()
    }

    private func settingTableView() {
        itemTableView.delegate = self
        itemTableView.dataSource = self
        itemTableView.register(ItemTableViewCell.nib,
                               forCellReuseIdentifier: ItemTableViewCell.identifire)
    }

    // KVOを使用
    private func setupBindings() {
        disposeBag.insert(
            itemViewModel.observe(\ItemViewModel.itemData,
                                  options: [.initial, .new],
                                  changeHandler: { [weak self] _, change in
                                    self?.items = change.newValue!.items
                                    self?.itemTableView.reloadData()
                                  })
        )
    }

    // MARK: - @IBAction
    @IBAction private func tappedAddBtn(_ sender: Any) {
        // navigationControllerで遷移
        let inputViewController = UINavigationController(
            rootViewController: InputViewController
                .instantiate(itemViewModel: itemViewModel, mode: .add, editingIndex: nil)
        )
        present(inputViewController, animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.identifire)
            as! ItemTableViewCell // swiftlint:disable:this force_cast
        cell.configure(item: items[indexPath.row])
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemViewModel.toggleIsChecked(at: indexPath.row)
        itemTableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // navigationControllerで遷移
        let inputViewController = UINavigationController(
            rootViewController: InputViewController
                .instantiate(itemViewModel: itemViewModel, mode: .edit, editingIndex: indexPath.row)
        )
        present(inputViewController, animated: true, completion: nil)
    }
}
