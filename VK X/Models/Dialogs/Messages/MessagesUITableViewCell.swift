//
//  MessagesUITableViewCell.swift
//  VK X
//
//  Created by Artem Kufaev on 01.06.2018.
//  Copyright © 2018 Artem Kufaev. All rights reserved.
//

import UIKit
import RealmSwift

class MessagesUITableViewCell: UITableViewCell {
  @IBOutlet weak var message: UILabel!
  
  @IBOutlet weak var messageBox: RoundUIView!
  
  @IBOutlet weak var messageDate: UILabel!
  
  @IBOutlet weak var senderPhoto: RoundUIImageView!
  
  override func prepareForReuse() {
    backgroundColor = nil
  }
}

extension MessagesUITableViewCell {
  func setSenderPhoto(_ dialog: VKDialogModel, _ message: VKMessageModel, _ indexPath: IndexPath) {
    guard !message.isOut else { return }
    
    guard (indexPath.row == 0 || dialog.messages[indexPath.row - 1].fromId != message.fromId) else {
      senderPhoto.image = nil
      return
    }
    
    var photo = dialog.photo100
    
    if dialog.type == "chat" {
      
      var users: Results<VKUserModel> = RealmService.loadData()!.filter("id = \(message.userId)")
      users = users.filter("id = \(message.userId)")
      
      if !users.isEmpty {
        photo = users.first!.photo100
      }
      
    }
    
    senderPhoto.sd_setImage(with: URL(string: photo), completed: nil)
  }
  
  func setBackgroudColor(_ message: VKMessageModel) {
    guard !message.isRead else { return }
    
    backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9411764706, blue: 0.9607843137, alpha: 1)
  }
}
