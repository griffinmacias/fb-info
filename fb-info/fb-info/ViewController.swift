//
//  ViewController.swift
//  fb-info
//
//  Created by Mason Macias on 8/30/17.
//  Copyright © 2017 griffinmacias. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

class ViewController: UIViewController {
    var loginButton: LoginButton?
    var userInfoView: UserInfoView?
    var user: User?
    override func viewDidLoad() {
        super.viewDidLoad()
        createFbLoginButton()
        if let _ = AccessToken.current {
            getFbInfo()
        }
        
        let userInfoView = UserInfoView()
        view.addSubview(userInfoView)
        let margins = view.layoutMarginsGuide
        userInfoView.translatesAutoresizingMaskIntoConstraints = false
        userInfoView.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        userInfoView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        userInfoView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        userInfoView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        self.userInfoView = userInfoView

        
    }
    
    func updateUserView() {
        if let user = self.user,
            let first = user.first,
            let last = user.last,
            let email = user.email,
            let pictureUrl = user.pictureUrl,
            let userInfoView = self.userInfoView  {
            userInfoView.nameLabel.text = "\(first) \(last)"
            userInfoView.emailLabel.text = email
            
            if let pictureURL = URL(string: pictureUrl) {
                let session = URLSession(configuration: .default)
                let downloadPicTask = session.dataTask(with: pictureURL) { (data, response, error) in
                    if let error = error {
                        print("Error downloading cat picture: \(error)")
                    } else {
                        if let res = response as? HTTPURLResponse {
                            print("Downloaded fb profile picture with response code \(res.statusCode)")
                            if let imageData = data {
                                let image = UIImage(data: imageData)
                                DispatchQueue.main.async {
                                    userInfoView.imageView.image = image
                                }
                            } else {
                                print("Couldn't get image: Image is nil")
                            }
                        } else {
                            print("Couldn't get response code for some reason")
                        }
                    }
                }
                
                downloadPicTask.resume()
            }
        }
    }
    
    func createFbLoginButton() {
        loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
        if let loginButton = loginButton {
            loginButton.delegate = self
            view.addSubview(loginButton)
            loginButton.translatesAutoresizingMaskIntoConstraints = false
            let margins = view.layoutMarginsGuide
            loginButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -16).isActive = true
            loginButton.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        }
    }
    
    func getFbInfo() {
        let request = GraphRequest(graphPath: "me",
                                   parameters: [ "fields": "first_name, last_name, picture, email" ])
        request.start { (response, result) in
            switch result {
            case .failed(let error):
                print(error)
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    print(responseDictionary)
                    self.user = User(responseDictionary)
                    self.updateUserView()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: LoginButtonDelegate {
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .success(let grantedPermissions, let declinedPermissions, let accessToken):
            print(accessToken)
            print(grantedPermissions)
            print(declinedPermissions)
            getFbInfo()
        case .cancelled:
            print("cancelled")
        case .failed(let error):
            print(error)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print(loginButton)
    }
}
