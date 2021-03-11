//
//  ChoicePopupVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 5/21/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import UIKit

protocol ChoiceDelegate {
    func didSelectChoice(choice: String)
}

class ChoicePopupTBViewCell: UITableViewCell{
    @IBOutlet weak var choiceTitleLbl: UILabel!
    @IBOutlet weak var choiceView: PositageView!
    
    func configure(with title: String){
        choiceTitleLbl.text = title
    }
}

enum ChoiceStyle {
    case destructive
    case normal
}

struct Choice {
    var title: String
    var style: ChoiceStyle
}
class ChoicePopupVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLbl: UILabel!

    public var delegate: ChoiceDelegate!
    var choices: [Choice]!
    var choicesTitle: String = "Choose:"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleLbl.text = choicesTitle
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "choiceCell") as? ChoicePopupTBViewCell {
            cell.configure(with: choices[indexPath.row].title)
            cell.choiceView.backgroundColor = (choices[indexPath.row].style ==  ChoiceStyle.destructive) ? #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 0.543717253) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.choiceTitleLbl.textColor = (choices[indexPath.row].style ==  ChoiceStyle.destructive) ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0.1509479284, green: 0.3276354074, blue: 0.6117966771, alpha: 0.7954247754)

            
            
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        getCurrentViewController()?.dismiss(animated: true){
            self.delegate.didSelectChoice(choice: self.choices[indexPath.row].title)

        }
    }
    
    
    
    
}

