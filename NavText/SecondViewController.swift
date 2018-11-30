//
//  SecondViewController.swift
//  NavText
//
//  Created by Merlin Zhao on 6/26/18.
//  Copyright © 2018 Merlin Zhao. All rights reserved.
//

import UIKit
import MessageUI     //import message UI
import CoreLocation //import CoreLocation

//STRUCTURE FOR CELL DATA FOR RECENT SEARCH TABLE VIEW
struct CellDataTwo{
    let mainMessage : String?
    let subMessage : String?
}
//LIST OF STRUCTURES
var recentListTwo = [CellDataTwo]()

class SecondViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, MFMessageComposeViewControllerDelegate {

    let screenSize: CGRect = UIScreen.main.bounds //get the screens ize

    //ENTER LCOATION TEXT FIELD BUTTON
    @IBOutlet weak var enterLocation: UIButton!
    @IBAction func enterLocation(_ sender: Any) {
        showSearchOne()
    }
    //FIND LOCATION BUTTON
    @IBOutlet weak var findLocation: UIButton!
    @IBAction func findLocation(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        if (MFMessageComposeViewController.canSendText()) {
            let recipients:[String] = ["12262860381"] //This is the phone number you type in
            let messageController = MFMessageComposeViewController()
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            
            
            messageController.messageComposeDelegate  = self
            messageController.recipients = recipients
            messageController.body = "description," + enterLocation.titleLabel!.text!//this is your body txt you type in
            self.present(messageController, animated: true, completion: nil)
        }
        else{
            print("error")
        }
    }
    //FIND WEATHER BUTTON
    @IBOutlet weak var weatherButton: UIButton!
    @IBAction func weatherButton(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        if (MFMessageComposeViewController.canSendText()) {
            let recipients:[String] = ["12262860381"] //This is the phone number you type in
            let messageController = MFMessageComposeViewController()
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            
            
            messageController.messageComposeDelegate  = self
            messageController.recipients = recipients
            messageController.body = "weather,43.004132, -81.276233"//this is your body txt you type in
            self.present(messageController, animated: true, completion: nil)
        }
        else{
            print("error")
        }
        
    }
    
    
    
    //BLUR ADDRESS FIELD
    @IBOutlet weak var addressField: UITextField!
    
    //recent lcoations label
    @IBOutlet weak var recent: UILabel!
    
   
    @IBOutlet weak var blurView: UIVisualEffectView!
    //DONE BUTTON
    @IBOutlet weak var cancelBlur: UIButton!
    @IBAction func cancelBlur(_ sender: Any) {
        hideSearch()
    }
    //tableView
    @IBOutlet weak var myTableView: UITableView!
    
    //************************************
    // **** FUNCTION TO CANCEL SEARCH VIEW / BLUE **********************************
    
    @objc func hideSearch() {
        
        //This funciton corresponds to the DONE button.
       
        //change the buttons while  not empty
        if addressField.text != "" && addressField.text != " " {
            enterLocation.setTitle(addressField.text!, for: .normal)
            updateTable()
        }
        addressField.resignFirstResponder() //end text field editing
        UIView.animate(withDuration: 0.4, animations: {
            self.blurView.center.y = self.screenSize.height * 1.8
            self.blackView.alpha = 0
            self.recent.alpha = 0
        })
        addressField.text = ""
    }
    
    @objc func updateTable() {
        //remove if list too long
        if recentListTwo.count == 12 {
            recentListTwo.remove(at: 11)
        }
        print(addressField.text!)
        print("updaeTable ----------------------_")
        print(recentListTwo)
        recentListTwo.insert(CellDataTwo(mainMessage: addressField.text!, subMessage: getDateTime()), at: 0)
        self.myTableView.reloadData() //add and reload to table
        //deleteFromArray(num: 3) //check to see if array is too long
    }
    
    
    
    
    // **** FUNCTION TO CALL SEARCH/BLUR VIEW ************************************** SHOW SEARCH ONE
    //first step
    let blackView = UIView()      //create black view
    
    func showSearchOne(){
        if let window = UIApplication.shared.keyWindow {   //acccess to the entire screen
                           //create a subview for black
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(blackView)
            window.addSubview(blurView) //add the blur view
            
            //swipe up
            let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
            upSwipe.direction = .up
            blurView.addGestureRecognizer(upSwipe)
            
           
        
            //black view things
            blackView.frame = window.frame          //get the window to cover entire screen
            blackView.alpha = 0
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSearch))) //tap black part to cancel
            
            
            //blur view things
            let height: CGFloat = 200
            let y = window.frame.height - height
            
            blurView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: window.frame.height)
            
            addressField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSearchTwo)))
            
            
            //animate -----------
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations:{ self.blackView.alpha = 0.7
                self.blurView.frame = CGRect(x: 0, y: y + 40, width: self.blurView.frame.width, height: self.blurView.frame.height )
            },
                completion: nil)
        }
        
    }
    //second step -> hidden button ***********
    @objc func showSearchTwo(){
        addressField.becomeFirstResponder() //start editing text field
        if let window = UIApplication.shared.keyWindow {
            
            let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
            downSwipe.direction = .down
            blurView.addGestureRecognizer(downSwipe)
            
            blackView.alpha = 0.7
           
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSearch))) //tap black part to cancel
       
            let y = window.frame.height - (window.frame.height - 60)
            
            //animate --------
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                //hide buttons
                self.recent.alpha = 1 //show recent label
            
                self.blackView.alpha = 1
                self.blurView.frame = CGRect(x: 0, y: y, width: self.blurView.frame.width, height: self.blurView.frame.height)
                
                }, completion: nil)
            
        }
    }
    
        
    //****DISMISS SEARCH
    
    @objc func dismissSearch(){
        addressField.resignFirstResponder() //end text field editing

        addressField.text = ""
        UIView.animate(withDuration: 0.4, animations: {
            self.blurView.center.y = self.screenSize.height * 1.8
            self.blackView.alpha = 0
        })
        
    }
    
    //DOWN AND UP SWIPE =========================
    @objc func handleSwipe(sender: UISwipeGestureRecognizer){
        if sender.state == .ended{
            switch sender.direction{
            case .down:
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
                hideSearch()
            case .up:
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
                showSearchTwo()
            default:
                break
            }
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.myTableView.register(recentCustomCell.self, forCellReuseIdentifier: "recentCellTwo")
        self.myTableView.rowHeight = UITableView.automaticDimension
        self.myTableView.estimatedRowHeight = 200
        
        
        enterLocation.layer.cornerRadius = 8
        cancelBlur.layer.cornerRadius = 8
        //-------
        blurView.layer.cornerRadius = 8
        blurView.clipsToBounds = true
        addressField.layer.cornerRadius = 8
        cancelBlur.layer.cornerRadius = 8
        recent.alpha = 0
        //
        findLocation.layer.cornerRadius = 8
        weatherButton.layer.cornerRadius = 8
    }
    
     // V I E W    D I D     A P P E A R
    override func viewDidAppear(_ animated: Bool) {
        
        //BLUR VIEW INTIAL STATE
        let screenSize: CGRect = UIScreen.main.bounds
        blurView.frame = CGRect(x: 0, y: self.screenSize.height, width: self.screenSize.width, height: self.screenSize.height)
        
        
    }
    //GET THE DATE AND TIME
    func  getDateTime() -> String{
        let formatter = DateFormatter()
        
        formatter.dateFormat = "hh:mm a MMMM dd, YYYY"
        let dateString = formatter.string(from: Date())
        return dateString
    }
    
    
    //TABLE VIEW ================================================================= TABLE VIEW
    
    //TABLE VIEW REQUIRED
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recentListTwo.count
    }
    
    //SET UP TABLE VIEW CELLS
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.myTableView.dequeueReusableCell(withIdentifier: "recentCellTwo") as! recentCustomCell
        cell.mainMessage = recentListTwo[indexPath.row].mainMessage
        cell.subMessage = recentListTwo[indexPath.row].subMessage
       
        cell.layoutSubviews() //load sizing!
        
        cell.backgroundColor = UIColor(white: 0, alpha: 0)
        print("New")
        return cell
        
    }
    
    //SLIDE TO DELETE
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            recentListTwo.remove(at: indexPath.row)
    
            tableView.reloadData()
 
        }
    }
    
    //TAP FOR ACTION
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    
    
    //MESSAGE COMPOSE VIEW CONTROLLER
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //TAP TO DISMISS KEYBOARD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


}

