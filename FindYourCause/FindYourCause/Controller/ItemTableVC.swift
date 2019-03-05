//
//  ItemTableVC.swift
//  FindYourCause
//
//  Created by Laksh on 02/03/19.
//  Copyright © 2019 Laksh. All rights reserved.
//

import UIKit

class ItemTableVC: UITableViewController {

    var items = [item]()
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    private func loadSampleMeal(){
        let image1 = UIImage(named: "defaultPhoto")
        let image2 = UIImage(named: "defaultPhoto")
        let image3 = UIImage(named: "defaultPhoto")
        
        guard let item1 = item(itemName: "surf excel", itemSatisfaction: "100", itemPrice: "30", itemImage: image1)else{
            fatalError("not working")
        }
        guard let item2 = item(itemName: "LEGO toy", itemSatisfaction: "60", itemPrice: "200", itemImage: image2) else{
            fatalError("not loading item 2")
        }
        guard let item3 = item(itemName: "iPhone", itemSatisfaction: "100", itemPrice: "10000", itemImage: image3) else{
            fatalError("not loading item 3")
        }
        
        
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell",for:indexPath) as? ItemTableViewCell else{
            fatalError("table view function broke")
        }
        let itemCell = items[indexPath.row]
        
        cell.itemName.text=itemCell.itemName
        cell.itemImage.image = itemCell.itemImage
        cell.itemPrice.text = itemCell.itemPrice
        cell.itemRating.text = cell.itemRating.text!+itemCell.itemSatisfaction
        
        return cell
        
    }

}
