//
//  LoginViewController.swift
//  BoredBets
//
//  Created by Sam Sobell on 10/25/16.
//  Copyright © 2016 SauceKitchen. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate, UITextFieldDelegate {

    var overlay: UIView!
    
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    override func viewDidLoad() {
        self.emailOutlet.delegate = self
        self.passwordOutlet.delegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func storeCurrentUserId(user_id : String){
        UserDefaults.standard.set(user_id, forKey: "user_id")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }

    @IBAction func createAccountAction(_ sender: AnyObject)
    {
        self.overlay = BBUtilities.showOverlay(view: self.view)
        if self.emailOutlet.text == "" || self.passwordOutlet.text == ""
        {
            BBUtilities.removeOverlay(overlay: self.overlay)
            BBUtilities.showMessagePrompt("Please enter an email and password.", controller: self)
        }
        else if (self.emailOutlet.text?.characters.count)! > 50 {
            BBUtilities.removeOverlay(overlay: self.overlay)
            BBUtilities.showMessagePrompt("Please enter a valid email.", controller: self)
        }
        else if (self.passwordOutlet.text?.characters.count)! > 50 {
            BBUtilities.removeOverlay(overlay: self.overlay)
            BBUtilities.showMessagePrompt("Please enter a shorter password.", controller: self)
        }

        else
        {
            FIRAuth.auth()?.createUser(withEmail: self.emailOutlet.text!, password: self.passwordOutlet.text!) { (user, error) in
                
                if error == nil {
                    self.storeCurrentUserId(user_id: (user?.uid)!)
                    self.performSegue(withIdentifier: "createProfileSegue", sender: nil)
                }
                else
                {
                    BBUtilities.removeOverlay(overlay: self.overlay)
                    BBUtilities.showMessagePrompt(error!.localizedDescription, controller: self)
                }
            }
        }
    }
    
    @IBAction func loginAction(_ sender: AnyObject)
    {
        self.overlay = BBUtilities.showOverlay(view: self.view)
        if self.emailOutlet.text == "" || self.passwordOutlet.text == ""
        {
            BBUtilities.removeOverlay(overlay: self.overlay)
            BBUtilities.showMessagePrompt("Please enter an email and password.", controller: self)
        }
        else
        {
            FIRAuth.auth()?.signIn(withEmail: self.emailOutlet.text!, password: self.passwordOutlet.text!) { (user, error) in
                
                if error == nil {
                    self.storeCurrentUserId(user_id: (user?.uid)!)

                    User.usersRef().child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.hasChild("username"){
                            self.performSegue(withIdentifier: "login", sender: nil)
                        }
                        else{
                            self.performSegue(withIdentifier: "createProfileSegue", sender: nil)
                        }

                    }) { (error) in
                        print(error.localizedDescription)
                    }
                }
                else
                {
                    BBUtilities.removeOverlay(overlay: self.overlay)
                    BBUtilities.showMessagePrompt(error!.localizedDescription, controller: self)
                }
            }
        }
    }
}
