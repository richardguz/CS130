//
//  SearchViewController.swift
//  BoredBets
//
//  Created by Kyle Baker on 11/17/16.
//  Copyright © 2016 SauceKitchen. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {
    
    // MARK: - Properties
    var filteredBets = [Bet]()
    var bets = [Bet]()
    var selectedBet: Bet?
    
    var users = [User]()
    var filteredUsers = [User]()
    var selectedUser: User?
    
    var scope = "Bets"
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController?.navigationBar.isTranslucent = true
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.scopeButtonTitles = ["Bets", "Users"]
        tableView.tableHeaderView = searchController.searchBar
        
        self.loadBetsAndUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isTranslucent = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isTranslucent = false
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.searchController.isActive && self.searchController.searchBar.text != "") {
            if (self.scope == "Bets") {
                return self.filteredBets.count
            }
            else {
                return self.filteredUsers.count
            }
        }
        if (self.scope == "Bets") {
            return self.bets.count
        }
        else {
            return self.users.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ActiveBetTableViewCell
        let userCell: UserTableViewCell
        let bet: Bet
        let user: User
        if (self.scope == "Bets") {
            cell = tableView.dequeueReusableCell(withIdentifier: "BetCell", for: indexPath) as! ActiveBetTableViewCell
            if (searchController.isActive && searchController.searchBar.text != "") {
                bet = filteredBets[(indexPath as NSIndexPath).row]
            }
            else {
                bet = self.bets[(indexPath as NSIndexPath).row]
            }
            cell.titleLabel.text = bet.title
            cell.potLabel.text = String(bet.pot)
            if (bet.mediatorId != nil){
                User.getUsernameById(bet.mediatorId, completion: {
                    username in
                    cell.mediatorLabel.text = username
                })
            }
            if (bet.pot < 50){
                cell.coinImageView.image = UIImage(named: "coin2")
            }
            else if(bet.pot < 400){
                cell.coinImageView.image = UIImage(named: "SmallStackCoins")
            }
            else{
                cell.coinImageView.image = UIImage(named: "StackedCoins")
            }
            return cell
        }
        else {
            userCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
            if (searchController.isActive && searchController.searchBar.text != "") {
                user = filteredUsers[(indexPath as NSIndexPath).row]
            }
            else {
                user = users[(indexPath as NSIndexPath).row]
            }
            userCell.username.text = user.username
            if ((user.rating) != nil) {
                userCell.rating.text = "Rating: " + String(user.rating)
            }
            else {
                userCell.rating.text = "Rating: N/A"
            }
            return userCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.scope == "Bets") {
            if (searchController.isActive && searchController.searchBar.text != "") {
                self.selectedBet = self.filteredBets[indexPath.row]
                performSegue(withIdentifier: "searchToBet", sender: self)
            }
            else {
                self.selectedBet = self.bets[indexPath.row]
                performSegue(withIdentifier: "searchToBet", sender: self)
            }
        }
        else {
            if (searchController.isActive && searchController.searchBar.text != "") {
                self.selectedUser = self.filteredUsers[indexPath.row]
                performSegue(withIdentifier: "searchToUser", sender: self)
            }
            else {
                self.selectedUser = self.users[indexPath.row]
                performSegue(withIdentifier: "searchToUser", sender: self)
            }
        }
    }
    
    func fillSearchMatches(_ searchText: String, scope: String = "Bets") {
        if (scope == "Bets") {
            self.scope = "Bets"
            filteredBets = bets.filter({( bet : Bet) -> Bool in
                return bet.title.lowercased().contains(searchText.lowercased())
            })
        }
        else {
            self.scope = "Users"
            filteredUsers = users.filter({( user : User) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            })
        }
        tableView.reloadData()
    }
    
    func loadBetsAndUsers() {
        let user = User(id: User.currentUser())
        user.betsWithinVicinity(latParm: 0, longParm: 0, radMiles: 12500000, completion: {
            bets in
            self.bets = bets
        })
        user.allUsers(completion: {
            users in
            self.users = users
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "searchToBet") {
            let vbvc = segue.destination as! ViewBetViewController
            vbvc.bet = self.selectedBet
        }
        else if (segue.identifier == "searchToUser") {
            let vpvc = segue.destination as! ViewProfileViewController
            vpvc.userId = self.selectedUser?.id
        }
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        fillSearchMatches(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension SearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        fillSearchMatches(searchController.searchBar.text!, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
    }
}
