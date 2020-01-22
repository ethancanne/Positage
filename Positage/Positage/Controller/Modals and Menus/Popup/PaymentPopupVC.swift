//
//  PaymentPopupVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/16/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//


struct Price {
    let label: String
    let numStamps: Int
}


import UIKit
class PricingCell: UITableViewCell {

    @IBOutlet weak var pricingLbl: UILabel!
    @IBOutlet weak var numStampsLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func ConfigureCell(price: Price){
        pricingLbl.text = price.label
        numStampsLbl.text = String(price.numStamps)
    }
}


import UIKit
class PaymentPopupVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    public var cost: Int!
    public var communityPost: CommunityPost?
    public var post: Post?
    public var group: Group?
    public var pricingItems: [Price]!

    
    @IBOutlet weak var totalCostNumLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        var totalPrice: Int
//        for (i, price) in pricingItems.enumerated(){
//            totalPrice += pricingItems![i].numStamps
//        }
        totalCostNumLbl.text = String(cost)
        
    }
    
    @IBAction func processTapped(_ sender: Any) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pricingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "pricingCell") as? PricingCell {
            cell.ConfigureCell(price: pricingItems[indexPath.row])
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    
    
}
