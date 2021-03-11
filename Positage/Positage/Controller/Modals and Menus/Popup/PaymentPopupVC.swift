//
//  PaymentPopupVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/16/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//


protocol PaymentDelegate{
    func didReturnFromPayment(isSuccessfull: Bool)
}

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

    func configureCell(price: Price){
        pricingLbl.text = price.label
        numStampsLbl.text = String(price.numStamps)
    }
}


import UIKit
class PaymentPopupVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    public var cost: Int = 0
    public var pricingItems: [Price]!
    public var delegate: PaymentDelegate!

    
    @IBOutlet weak var totalCostNumLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for price in pricingItems{
            cost += price.numStamps
        }
        totalCostNumLbl.text = String(cost)
        tableView.reloadData()
    }
    
    @IBAction func processTapped(_ sender: Any) {
        //Process payment and return to caller to finish transaction.
        LoadingVC.showLoadingScreen(withMessage: "Completing Purchase")
        let userStamps = DataService.currentUserNumStamps
        print(userStamps)
        if cost <= userStamps{
            DataService.database.collection(USERS_REF).document(DataService.currentUser!.userId).updateData(
            [NUM_STAMPS : (userStamps - cost)]) { (error) in
                if error != nil{
                    print("Error completing purchase: \(error.debugDescription)")
                    self.delegate.didReturnFromPayment(isSuccessfull: false)
                }
            }
            print("Purchase completed successfully.")
            delegate.didReturnFromPayment(isSuccessfull: true)
            return
        } else{
            delegate.didReturnFromPayment(isSuccessfull: false)
        }


    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pricingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "pricingCell") as? PricingCell {
            cell.configureCell(price: pricingItems[indexPath.row])
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    
    
}
