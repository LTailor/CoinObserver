//
//  ViewController.swift
//  CoinObserver
//
//  Created by Dzhambulat Khasayev on 08.01.18.
//  Copyright © 2018 ReseaSoft. All rights reserved.
//

import UIKit
import UserNotifications

class CoinInfoTableViewCell:UITableViewCell
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    var rateId:Int?
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var coinTable: UITableView!

    var coinInfo:[Coin] = []
    var coinInteractor:CoinInfoInteractor?
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in })
        let rts = [RateInfo(firstName: "btc",secondName: "usd"),RateInfo(firstName: "eth",secondName: "usd"),RateInfo(firstName: "xrp",secondName: "usd")]
        coinInteractor = CoinInfoInteractor.instance
        coinInteractor?.addDelegate({ci in
            self.coinInfo = ci!
            self.coinTable.reloadData()
        })
      //  AlertManager.instance.updateAlert(Alert(2,AlertCondition.greater,value: 10000,id: 0))
      //  AlertManager.instance.updateAlert(Alert(2,AlertCondition.less,value: 12000,id: 0))
        coinInteractor?.start()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return coinInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CoinInfoTableViewCell
        
        let coinInfo = self.coinInfo[indexPath.row]
        cell.nameLabel.text = coinInfo.name
        cell.priceLabel.text = String(coinInfo.price)
        cell.rateId = coinInfo.id
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! CoinInfoTableViewCell
        performSegue(withIdentifier: "showAlerts", sender: cell.rateId)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAlerts" {
            if let destinationVC = segue.destination as? UINavigationController {
                
                (destinationVC.topViewController as? AlertsViewController)?.rateId = sender as? Int
            }
        }
    }

}

