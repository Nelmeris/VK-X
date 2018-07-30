//
//  MessagesUIViewController.swift
//  VK X
//
//  Created by Artem Kufaev on 01.06.2018.
//  Copyright © 2018 Artem Kufaev. All rights reserved.
//

import UIKit
import RealmSwift

class MessagesUIViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var message: UITextView!
  @IBOutlet weak var tableViewTopSpace: NSLayoutConstraint!
  @IBOutlet weak var messageHC: NSLayoutConstraint!
  
  var dialog: VKDialogModel!
  var dialogId: Int!
  var messagesCount: Int!
  
  var notificationToken: NotificationToken!
  
  let transform = CGAffineTransform(rotationAngle: -3.1415926)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = dialog.title
    
    setOnlineStatus(navigationItem)
    
    tableView.delegate = self
    tableView.dataSource = self
    
    message.delegate = self
    
    let tapScreen = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tapScreen.cancelsTouchesInView = false
    view.addGestureRecognizer(tapScreen)
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    tableView.transform = transform
    
    message.layer.cornerRadius = message.frame.height / 2
    message.layer.borderColor = #colorLiteral(red: 0.8901960784, green: 0.8980392157, blue: 0.9137254902, alpha: 1)
    message.layer.borderWidth = 1
    
    message.textContainer.lineFragmentPadding = 12
    
    message.text = nil
    message.placeholder = "Сообщение..."
    
    messagesCount = 100
    
    VKService.Methods.Messages.get(dialogId: dialogId, count: messagesCount) { [weak self] response in
      guard let strongSelf = self else { return }
      DispatchQueue.main.async {
        strongSelf.deleteOldMessages(dialog: (strongSelf.dialog)!, newMessages: response.messages)
        strongSelf.addNewMessages(dialog: (strongSelf.dialog)!, newMessages: response.messages)
        
        do {
          let realm = try Realm()
          realm.beginWrite()
          strongSelf.dialog.inRead = response.inRead
          strongSelf.dialog.outRead = response.outRead
          try realm.commitWrite()
        } catch let error {
          print(error)
        }
      }
    }
    
    RealmService.shared.pairTableViewAndData(sender: tableView, token: &notificationToken, data: AnyRealmCollection(dialog.messages), insertAnimation: .top)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dialog.messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let message = dialog.messages[indexPath.row]
    let cell: MessagesUITableViewCell
    
    let cellId = (message.isOut ? "MyMessage" : "SenderMessage")
    
    cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! MessagesUITableViewCell
    
    cell.transform = transform
    
    cell.messageDate.text = getDateString(message.date)
    cell.message.text = message.text
    
    cell.setBackgroudColor(message)
    cell.setSenderPhoto(dialog, message, indexPath)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let lastRow = indexPath.row
    let messagesLoadCount = 50
    if lastRow == messagesCount - 1 {
      VKService.Methods.Messages.get(dialogId: dialogId, startId: dialog.messages.last?.id, count: messagesLoadCount) { [weak self] response in
        guard let strongSelf = self else { return }
        DispatchQueue.main.async {
          strongSelf.deleteOldMessages(dialog: (strongSelf.dialog)!, newMessages: response.messages)
          strongSelf.addNewMessages(dialog: (strongSelf.dialog)!, newMessages: response.messages)
          
          do {
            let realm = try Realm()
            realm.beginWrite()
            strongSelf.dialog.inRead = response.inRead
            strongSelf.dialog.outRead = response.outRead
            try realm.commitWrite()
          } catch let error {
            print(error)
          }
        }
      }
      messagesCount! += messagesLoadCount
    }
  }
  
  func textViewShouldReturn(_ textField: UITextField) -> Bool {
    guard message.returnKeyType == .go else { return true }
    
    sendMessage(self)
    return true
  }
  
  func textViewDidChange(_ textView: UITextView) {
    messageHC.constant = message.contentSize.height
  }
  
  
  
  @IBAction func sendMessage(_ sender: Any) {
    guard message.text != "" else { return }
    
    VKService.Methods.Messages.send(dialogId: dialogId, messageText: message.text!)
    message.text = "Сообщение..."
    message.textColor = .lightGray
  }
}



extension MessagesUIViewController {
  func setOnlineStatus(_ navigationItem: UINavigationItem) {
    guard dialog.isOnline else { return }
    
    navigationItem.title = navigationItem.title! + " онлайн" + (!dialog.isOnlineMobile ? "" : " с телефона")
  }
  
  func addNewMessages(dialog: VKDialogModel, newMessages: [VKMessageModel]) {
    for newMessage in newMessages {
      guard !dialog.messages.contains(newMessage) else { continue }
      
      addNewMessage(dialog, newMessage)
    }
  }
  
  func addNewMessage(_ dialog: VKDialogModel, _ newMessage: VKMessageModel) {
    do {
      let realm = try Realm()
      realm.beginWrite()
      dialog.messages.append(newMessage)
      try realm.commitWrite()
    } catch let error {
      print(error)
    }
  }
  
  func deleteOldMessages(dialog: VKDialogModel, newMessages: [VKMessageModel]) {
    for message in dialog.messages {
      guard newMessages.contains(message) else { continue }
      
      RealmService.shared.deleteData([message])
    }
  }
}



extension MessagesUIViewController {
  @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  @objc func keyboardWillShown(notification: Notification) {
    let info = notification.userInfo! as NSDictionary
    let kbSize = (info.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
    
    let tabBarHeight = (self.tabBarController?.tabBar.frame.height)!
    
    let kbHeight = kbSize.height - tabBarHeight
    
    tableViewTopSpace.constant = kbHeight
    scrollView?.setContentOffset(CGPoint(x: 0, y: kbHeight), animated: true)
  }
  
  @objc func keyboardWillBeHidden(notification: Notification) {
    tableViewTopSpace.constant = 0
    scrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
  }
}
