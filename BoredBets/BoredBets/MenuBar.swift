//
//  MenuBar.swift
//  BoredBets
//
//  Created by Kyle Baker on 11/1/16.
//  Copyright © 2016 SauceKitchen. All rights reserved.
//

import UIKit

class MenuBar: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.rgb(red: 35, green: 145, blue: 35)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    var view: UINavigationController? = nil
    var currentPos = 0
    let cellId = "cellId"
    let imageNames = ["categories", "mediate", "trending", "account", "newbet"]
    var currentUser: User!
    
    init(frame: CGRect, currentPos: Int) {
        self.currentPos = currentPos
        super.init(frame: frame)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        User.getUserById(User.currentUser()) { (user) in
            self.currentUser = user
        }
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
    }
    
    func setCurrentPos(currentPos: Int) {
        self.currentPos = currentPos
    }
    
    func setView(view: UINavigationController) {
        self.view = view
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let n = indexPath.item
        if (n == 0) {
            let vc = storyboard.instantiateViewController(withIdentifier: "settings") as! CategoryViewController
            self.view?.pushViewController(vc, animated: true)
        }
        else if (n == 1) {
            let vc = storyboard.instantiateViewController(withIdentifier: "betsMediating") as! MediatingBetsViewController
            self.view?.pushViewController(vc, animated: true)
        }
        else if (n == 2) {
            let vc = storyboard.instantiateViewController(withIdentifier: "activeBets") as! ActiveBetsViewController
            self.view?.pushViewController(vc, animated: true)
        }
        else if (n == 3) {
            let vc = storyboard.instantiateViewController(withIdentifier: "viewProfile") as! ViewProfileViewController
            vc.user = self.currentUser
            self.view?.pushViewController(vc, animated: true)
        }
        else if (n == 4) {
            let vc = storyboard.instantiateViewController(withIdentifier: "createBet") as! SetBetDetailsViewController
            self.view?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell
        
        cell.imageView.image = UIImage(named: imageNames[(indexPath as NSIndexPath).item])?.withRenderingMode(.alwaysTemplate)
        cell.tintColor = UIColor.rgb(red: 0, green: 0, blue: 0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 5, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
