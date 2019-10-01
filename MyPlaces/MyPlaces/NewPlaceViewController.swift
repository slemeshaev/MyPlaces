//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Станислав Лемешаев on 01/10/2019.
//  Copyright © 2019 Станислав Лемешаев. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    // MARK: Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        } else {
            view.endEditing(true)
        }
    }
    
    
}

// MARK: Textfield delegate
extension NewPlaceViewController: UITextFieldDelegate {
    
    // Скрываем клавиатуру по нажатию клавиши Done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
