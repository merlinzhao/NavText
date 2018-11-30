//
//  recentCustomCell.swift
//  NavText
//
//  Created by Merlin Zhao on 7/12/18.
//  Copyright © 2018 Merlin Zhao. All rights reserved.
//

import UIKit

class recentCustomCell: UITableViewCell {
    var mainMessage : String?
    var subMessage : String?
    
    var mainMessageView : UILabel = {
        var mainTextView = UILabel()
        mainTextView.translatesAutoresizingMaskIntoConstraints = false
     
 
        return mainTextView
    }()
    
    var subMessageView : UILabel = {
       var subTextView = UILabel()
        subTextView.translatesAutoresizingMaskIntoConstraints = false
        
        return subTextView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(mainMessageView)
        self.addSubview(subMessageView)
        
        
        mainMessageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        mainMessageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        mainMessageView.bottomAnchor.constraint(equalTo: self.subMessageView.topAnchor).isActive = true
        mainMessageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 15).isActive = true
        mainMessageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        mainMessageView.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.bold)
        
        
        subMessageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        subMessageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        subMessageView.topAnchor.constraint(equalTo: self.mainMessageView.bottomAnchor ).isActive = true
        subMessageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 15).isActive = true
        subMessageView.heightAnchor.constraint(equalToConstant: 13).isActive = true
        
        subMessageView.textColor = UIColor(white: 0.9, alpha: 1)
        subMessageView.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.medium)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let message = mainMessage {
            mainMessageView.text = message
        }
        if let messageTwo = subMessage {
            subMessageView.text = messageTwo
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}


