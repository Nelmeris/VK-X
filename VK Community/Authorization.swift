//
//  Authorization.swift
//  VK Community
//
//  Created by Артем on 27.04.2018.
//  Copyright © 2018 NONE. All rights reserved.
//

import UIKit

var auth: Bool = false

class Authorization: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Настройка кнопки
        authButton.layer.cornerRadius = 10
        authButton.layer.borderWidth = 0.1
        authButton.layer.borderColor = (UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)).cgColor
        authButton.clipsToBounds = true
        
        //Настройка окна
        authView.layer.cornerRadius = 10
        authView.clipsToBounds = true
        
        //Скрытие клавиатуры при нажатии на внешнюю область
        let tapScreen = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapScreen.cancelsTouchesInView = false
        view.addGestureRecognizer(tapScreen)
        
        loginInput.delegate = self
        passwordInput.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            passwordInput.becomeFirstResponder()
        } else if textField.returnKeyType == .go {
            if shouldPerformSegue(withIdentifier: "LogIn", sender: self) {
                performSegue(withIdentifier: "LogIn", sender: self)
            }
        }
        return true
    }
    
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var authContent: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var resultOut: UILabel!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var authView: UIView!
    @IBOutlet weak var logo: UILabel!
    
    //Действие при открытии клавиатуры
    @objc func keyboardWillShown(notification: Notification) {
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        
        if kbSize.height + authView.frame.height + resultOut.frame.height + logo.frame.height >= view.frame.height {
            let contentInsets = UIEdgeInsetsMake(0, 0, kbSize.height, 0)
            scrollView?.contentInset = contentInsets
            scrollView?.scrollIndicatorInsets = contentInsets
        }
        
        scrollView?.setContentOffset(CGPoint(x: 0, y: kbSize.height / 2), animated: true)
    }
    
    //Действие при закрытии клавиатуры
    @objc func keyboardWillBeHidden(notification: Notification) {
        scrollView?.contentInset = UIEdgeInsets.zero
        scrollView?.scrollIndicatorInsets = UIEdgeInsets.zero
        scrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //Правило перехода
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        view.endEditing(true)
        if loginInput.text!.lowercased() == "root".lowercased() && passwordInput.text! == "root" {
            auth = true
        } else {
            let alert = UIAlertController(title: "Ошибка", message: "Введены неверные данные пользователя", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
        return auth
    }


}