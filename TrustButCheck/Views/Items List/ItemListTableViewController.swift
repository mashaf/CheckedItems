//
//  ItemListTableViewController.swift
//  TrustButCheck
//
//  Created by Maria Soboleva on 11/16/18.
//  Copyright © 2018 Jesse Flores. All rights reserved.
//

import UIKit
import CoreData

class ItemListTableViewController: UITableViewController {

    lazy var fetchedResultsController:NSFetchedResultsController = CheckedItems.getFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        
        fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
        
        tableView.bounces = false
        tableView.separatorInset = UIEdgeInsetsMake(0, 30, 0, 30)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        let nib = UINib(nibName: "ItemsListHeaderTableView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "ItemsListHeaderTableView")
        
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
        return UIView(frame: CGRect(x:0, y:0, width:tableView.bounds.width, height:60))
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "ItemsListHeaderTableView") as! ItemsListHeaderTableView
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemInfoCell", for: indexPath)  as! ItemTableViewCell
        let item = fetchedResultsController.object(at: indexPath) as! CheckedItems
        cell.nameLabel.text = item.item_name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        cell.dateFinishLabel.text = dateFormatter.string(from: item.finish_date! as Date)
        cell.spendLabel.text = String(item.spend_amount)
        cell.restLabel.text  = String(item.rest_amount)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = fetchedResultsController.object(at: indexPath) as! CheckedItems
        showAddItemScreen(for: item)
    }
    
    @objc func addNewItem() {
        showAddItemScreen(for: nil)
    }
    
    // MARK: private methods
    private func showAddItemScreen(for item:CheckedItems?) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addItemViewController = storyBoard.instantiateViewController(withIdentifier: "AddItemViewController") as! AddItemViewController
        addItemViewController.item = item
        self.navigationController?.pushViewController(addItemViewController, animated: true)
        
    }
    
}

// MARK: NSFetchedResultsControllerDelegate
extension ItemListTableViewController: NSFetchedResultsControllerDelegate {
}
