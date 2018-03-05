//
//  AlertsController.swift
//  CoinObserver
//
//  Created by Dzhambulat Khasayev on 26.01.18.
//  Copyright © 2018 ReseaSoft. All rights reserved.
//

import Foundation
import UIKit

class AlertTableViewCell:UITableViewCell
{
    var alertId:Int?
}

class AlertsViewController:UIViewController,UITableViewDelegate, UITableViewDataSource, AlertDetailsHandler{

    var rateId:Int?
    var alerts:[Alert]?
    @IBOutlet weak var alertsTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.

        alerts = AlertManager.instance.getAlerts(rateId!)
        alertsTable.reloadData()
    }
    
    @IBAction func backPushed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func refreshData()->Void
    {
        alerts = AlertManager.instance.getAlerts(rateId!)
        alertsTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(alerts != nil)
        {
            return (alerts?.count)!
        }
        else
        {
           return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AlertTableViewCell
        var condSymbol:String
        if(alerts != nil)
        {
        switch (alerts?[indexPath.row].condition)!
        {
        case .greater: condSymbol=">";
        case .equal: condSymbol="="
        case .less: condSymbol="<"
        }
        
        cell.textLabel?.text = condSymbol + " " + String((alerts?[indexPath.row].value)!)
        cell.alertId = alerts?[indexPath.row].id
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let cell = tableView.cellForRow(at: indexPath) as! AlertTableViewCell
            
            AlertManager.instance.removeAlert(id: cell.alertId!, rateId: self.rateId!)
            alerts = AlertManager.instance.getAlerts(rateId!)
            self.alertsTable.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! AlertTableViewCell
        
        tableView.deselectRow(at: indexPath, animated: true)
        let alert = AlertManager.instance.getAlert(rateId: rateId!, alertId: cell.alertId!)
        let alertDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "alertDetailsVC") as! UINavigationController
        var alertTopVC = alertDetailsVC.topViewController as? AlertViewController
        alertTopVC?.alert = alert
        alertTopVC?.delegate = self
        self.present(alertDetailsVC,animated:true,completion: nil )
    }
    
    func dismissed() {
        
    }
    
    func done(alert:Alert) {
        AlertManager.instance.updateAlert(alert)
        refreshData()
    }

    @IBAction func newAlertPushed(_ sender: Any) {
        let alertDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "alertDetailsVC") as! UINavigationController
        var alertTopVC = alertDetailsVC.topViewController as? AlertViewController
        alertTopVC?.alert = Alert(rateId!,AlertCondition(rawValue:"greater")!,value: 0.0,id: 0)
        alertTopVC?.delegate = self
        self.present(alertDetailsVC,animated:true,completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAlertDetails" {
            if let destinationVC = segue.destination as? AlertViewController {
                destinationVC.alert = sender as? Alert
            }
        }
    }
    

}
