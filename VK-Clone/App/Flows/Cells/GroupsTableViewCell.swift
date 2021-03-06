//
//  GroupsTableViewCell.swift
//  VK-Clone
//
//  Created by Artem Kufaev on 03.05.2018.
//  Copyright © 2018 Artem Kufaev. All rights reserved.
//

import UIKit

class GroupsTableViewCell: DataBasicTableViewCell {
    
    @IBOutlet weak var participantsCount: UILabel!
    
    func configure(with viewModel: GroupViewModel) {
        name.text = viewModel.name
        setPhoto(viewModel.photo)
    }
    
}
