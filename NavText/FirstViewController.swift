//
//  FirstViewController.swift
//  NavText
//
//  Created by Merlin Zhao on 6/26/18.
//  Copyright © 2018 Merlin Zhao. All rights reserved.
//

import UIKit
import MessageUI     //import message UI
import CoreLocation //import CoreLocation


//STRUCTURE FOR CELL DATA FOR RECENT SEARCH TABLE VIEW
struct CellData{
    let mainMessage : String?
    let subMessage : String?
}
//LIST OF STRUCTURES
var recentList = [CellData]()


class FirstViewController: UIViewController, MFMessageComposeViewControllerDelegate , UITableViewDelegate, UITableViewDataSource{

    
    
    //DECLARE VARIABLES-----------

    let screenSize: CGRect = UIScreen.main.bounds //get the screens ize
    var tempnum = 0
    var editMode = 0 //EDiting mode to keep track of entering starting/destination addres.  0 = start, 1 = destination
    
    //GET THE TIME---------------
    let date = Date()
    let calendar = Calendar.current
    
    
   
    var mode = "drive" //mode for drive, walk, or trnsit: default is drive
    
    //TEXTFIELD =========================================
    @IBOutlet weak var addressField: UITextField!
    
    
    
    //RIDE WITH UBER BUTTON
    @IBOutlet weak var uberImage: UIImageView!

    @IBOutlet weak var uberButtonOutlet: UIButton!
    @IBAction func uberButton(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        if (MFMessageComposeViewController.canSendText()) {
            let recipients:[String] = ["12262860381"] //This is the phone number you type in
            let messageController = MFMessageComposeViewController()
            let generatorMsg = UIImpactFeedbackGenerator(style: .medium)
            generatorMsg.prepare()
            generatorMsg.impactOccurred()
        
        
            messageController.messageComposeDelegate  = self
            messageController.recipients = recipients
            messageController.body = "Uber, 43.004132, -81.276233, 541 Oxford St W "
            self.present(messageController, animated: true, completion: nil)
        }
        else{
            print("error")
        }
        
        
    }
    
    
    //BUTTONS ==============================================================================================BUTTONS
    //==============================================================================================================
    
    //SEARCH BUTTON
    @IBOutlet weak var search: UIButton!
    @IBAction func search(_ sender: UIButton) {
        if (MFMessageComposeViewController.canSendText()) {
            let recipients:[String] = ["12262860381"] //This is the phone number you type in
            let messageController = MFMessageComposeViewController()
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            
            
            messageController.messageComposeDelegate  = self
            messageController.recipients = recipients
            messageController.body = mode + ", " + startAddress.titleLabel!.text! + ", " + destinationAddress.titleLabel!.text!//this is your body txt you type in
            self.present(messageController, animated: true, completion: nil)
        }
        else{
            print("error")
        }
    }


    //STARTING ADDRESS BUTTON
    
    @IBOutlet weak var startAddress: UIButton!
    @IBAction func startAddress(_ sender: Any) {

        editMode = 0 // set edit mode to starting
        addressField.placeholder = "Enter starting address"
   
        showSearchOne()
    }
    
    //DESTINATION ADDRESS BUTTON
    
    @IBOutlet weak var destinationAddress: UIButton!
    @IBAction func destinationAddress(_ sender: Any) {
        
       
        editMode = 1 //set edit mode to destination
        addressField.placeholder = "Enter destination address"
        showSearchOne()
        
        
    }
    var currentLocation = "Western University, London ON"
    var homeLocation = "McMaster University, Hamilton ON"
    
    //MY LCOATION BUTTON

    @IBOutlet weak var myLocation: UIButton!
    @IBAction func myLocation(_ sender: Any) {
        if editMode == 0{
            startAddress.setTitle( currentLocation, for: .normal)
         
        
        } else if editMode == 1{
            destinationAddress.setTitle( currentLocation,for: .normal)
        }
        hideSearch()
    }
    
    //HOME BUTTON
    
    @IBOutlet weak var home: UIButton!
    @IBAction func home(_ sender: Any) {
        if editMode == 0{
            startAddress.setTitle(homeLocation, for: .normal)
        } else if editMode == 1{
            destinationAddress.setTitle( homeLocation,for: .normal)
        }
        hideSearch()
    }
    
    
    //=======================================================================================================================
    //MODE OF TRANSPORTATION PICKER ==========================================================================================
    
    @IBOutlet weak var modePicker: UISegmentedControl!
    @IBAction func modePicker(_ sender: UISegmentedControl) {
        switch modePicker.selectedSegmentIndex
        {
        case 0:
            mode = "Drive"
        case 1:
            mode = "Walk"
        case 2:
            mode = "Transit"
        default:
            break
        }
    }
    
 
    
    
    //BLUR VIEW ==========================================
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    //RECENT LABEL IN BLUR VIEW
    
    @IBOutlet weak var recent: UILabel!
    
  
    //CANCEL BLUR BUTTON
    @IBOutlet weak var cancelBlur: UIButton!
    @IBAction func cancelBlur(_ sender: Any) {
        hideSearch()
        print(addressField.text!)
    }
    
    //TABLE VIEW ======================================
    
    @IBOutlet weak var myTableView: UITableView!

    
    //******************************* SELF MADE FUNCTIONS ************************************
    // **** FUNCTION TO CANCEL SEARCH VIEW / BLUE **********************************
    
    @objc func hideSearch() {
        
        //This funciton corresponds to the DONE button.
       
        //change the buttons while  not empty
        if addressField.text != "" && addressField.text != " " {
            if editMode == 0{
                startAddress.setTitle(addressField.text!, for: .normal)
                print(addressField.text!)
                print("Start: " + addressField.text!)
            
            } else if editMode == 1{
                destinationAddress.setTitle( addressField.text!, for: .normal)
            }
            updateTable()
        }
        
  
        addressField.resignFirstResponder() //end text field editing
        UIView.animate(withDuration: 0.4, animations: {
            self.blurView.center.y = self.screenSize.height * 1.8
            self.blackView.alpha = 0
            
            
        })
        
        addressField.text = ""
        
    }
    
    @objc func updateTable() {
        //remove if list too long
        if recentList.count == 12 {
            recentList.remove(at: 11)
                
        }
        recentList.insert(CellData(mainMessage: addressField.text!, subMessage: getDateTime()), at: 0)
        self.myTableView.reloadData() //add and reload to table
        //deleteFromArray(num: 3) //check to see if array is too long
        
     
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
            
            //bring back buttons
            self.myLocation.alpha = 1
            self.home.alpha = 1
            self.recent.alpha = 0 //hide recent label
        
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
                self.myLocation.alpha = 0
                self.home.alpha = 0
                self.recent.alpha = 1 //show recent label
                
                self.blackView.alpha = 1
                self.blurView.frame = CGRect(x: 0, y: y, width: self.blurView.frame.width, height: self.blurView.frame.height)
                
                }, completion: nil)
            
        }
  
    }


    
    //GET THE DATE AND TIME
    func  getDateTime() -> String{
        let formatter = DateFormatter()
        
        formatter.dateFormat = "hh:mm a MMMM dd, YYYY"
        let dateString = formatter.string(from: Date())
        return dateString
    }
    
    
    
    
    // V I E W    D I D     A P P E A R
    override func viewDidAppear(_ animated: Bool) {
        
        //BLUR VIEW INTIAL STATE
        let screenSize: CGRect = UIScreen.main.bounds
        blurView.frame = CGRect(x: 0, y: self.screenSize.height, width: self.screenSize.width, height: self.screenSize.height)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //initalize cell data
        //recentList = [CellData.init(mainMessage: " " + "T: 118 Wild Orchid Cres", subMessage: " " + "T: June 12, 5:12pm")]
        
      
        
        self.myTableView.register(recentCustomCell.self, forCellReuseIdentifier: "recentCell")
        self.myTableView.rowHeight = UITableView.automaticDimension
        self.myTableView.estimatedRowHeight = 200
        

      
        //-----------------
        
        startAddress.layer.cornerRadius = 5
        destinationAddress.layer.cornerRadius = 5
        //button radius
        myLocation.layer.cornerRadius = 8
        home.layer.cornerRadius = 8
        //-------
        blurView.layer.cornerRadius = 8
        blurView.clipsToBounds = true
        addressField.layer.cornerRadius = 8
        cancelBlur.layer.cornerRadius = 8

        //------
        search.layer.cornerRadius = 8
        //uber radius
        uberImage.layer.cornerRadius = 8
        uberButtonOutlet.layer.cornerRadius = 8
        uberButtonOutlet.clipsToBounds = true
    
        
    }
    
    //DELETE IF ARRAY TOO LONG
    func deleteFromArray(num : Int) {
        if (recentList.count > num){
            recentList.removeLast()
        }
        
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
    

    
   
    
    //TABLE VIEW ================================================================= TABLE VIEW
    
    //TABLE VIEW REQUIRED
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recentList.count
    }
    
    //SET UP TABLE VIEW CELLS
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.myTableView.dequeueReusableCell(withIdentifier: "recentCell") as! recentCustomCell
        cell.mainMessage = recentList[indexPath.row].mainMessage
        cell.subMessage = recentList[indexPath.row].subMessage
       
        cell.layoutSubviews() //load sizing!
        
        cell.backgroundColor = UIColor(white: 0, alpha: 0)
        print("New")
        return cell
        
        
    }
    //SLIDE TO DELETE
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            recentList.remove(at: indexPath.row)
    
            tableView.reloadData()
 
        }
    }
    
    //TAP FOR ACTION
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissSearch()
        
        
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

/*
 Merlin Zhao...
 app dev.
 graphic designer.
 */

var aboutme = ["projects", "resume", "github", "linkedin"]
