//
//  ItemListTableViewController.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 11/16/18.
//  Copyright © 2018 Maria Soboleva. All rights reserved.
//

import UIKit
import CoreData

class ItemListTableViewController: UITableViewController {

    lazy var fetchedResultsController: NSFetchedResultsController = CheckedItems.getFetchedResultsController()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white

        fetchedResultsController.delegate = self

        tableView.bounces = false

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50

        let itemListNibName = "ItemsListHeaderTableView"
        let nib = UINib(nibName: itemListNibName, bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: itemListNibName)

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }

        let addNewItemButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewItem))
        self.navigationItem.rightBarButtonItem = addNewItemButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 60))
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let itemListHeaderViewId = "ItemsListHeaderTableView"
        guard let headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: itemListHeaderViewId) as? ItemsListHeaderTableView
        else {
            fatalError("Wrong header view id \(itemListHeaderViewId) for the table")
        }
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "itemInfoCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)  as? ItemTableViewCell else {
            fatalError("Wrong tableview cell id \(cellId)")
        }

        guard let item = fetchedResultsController.object(at: indexPath) as? CheckedItems else {
            return cell
        }

        cell.configure(with: item)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = fetchedResultsController.object(at: indexPath) as? CheckedItems else {
            fatalError("There are no object at \(indexPath) in the database")
        }
        showAddItemScreen(for: item)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let item = fetchedResultsController.object(at: indexPath) as? CheckedItems else {
            fatalError("There are no object at \(indexPath) in the database")
        }
        let deleteRowAction = UITableViewRowAction(style: .default, title: "Delete", handler: {_, _ in
            CheckedItemsViewModel.deleteCheckedItem(item)
        })
        let addRowAction = UITableViewRowAction(style: .normal, title: "Extend item", handler: {_, _ in
            self.showAddItemScreen(for: item)
        })
        return [deleteRowAction, addRowAction]
    }
    
    // MARK: Action methods
    @objc func addNewItem() {
        showAddItemScreen(for: nil)
    }

    // MARK: private methods
    private func showAddItemScreen(for item: CheckedItems?) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addItemVCId = "AddItemViewController"
        
        guard let addItemViewController = storyBoard.instantiateViewController(withIdentifier: addItemVCId) as? AddItemViewController else {
            fatalError("No view controller with id \(addItemVCId)")
        }
        
        if item != nil {
            addItemViewController.item = CheckItemViewModel(item: item!)
        }
        
        self.navigationController?.pushViewController(addItemViewController, animated: true)
    }
    
    private func showExtendItemScreen(for item: CheckedItems) {
        ///
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension ItemListTableViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        var whereToMoveAfter: IndexPath? // = indexPath // TODO

        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            whereToMoveAfter = newIndexPath
        case .delete:
            if indexPath!.row == tableView.numberOfRows(inSection: indexPath!.section) - 1 {
                let rowNum = indexPath!.row == 0 ? 0 : indexPath!.row - 1
                whereToMoveAfter = IndexPath(row: rowNum, section: indexPath!.section)
            } else {
                whereToMoveAfter = indexPath
            }
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            break
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
            whereToMoveAfter = newIndexPath
        }

        tableView.reloadData()
        //if whereToMoveAfter != nil {
        //    tableView.scrollToRow(at: whereToMoveAfter!, at: .none, animated: true)
        //}
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()

    }
}
