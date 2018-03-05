//
//  AlertDetailsController.swift
//  CoinObserver
//
//  Created by Dzhambulat Khasayev on 26.01.18.
//  Copyright © 2018 ReseaSoft. All rights reserved.
//

import Foundation
import UIKit

protocol AlertDetailsHandler {
    func dismissed() ->Void
    func done(alert:Alert)->Void
}

class AlertViewController:UIViewController,UIPickerViewDelegate, UIPickerViewDataSource
{
    var alertPickerData = ["Greater","Equal","Less"]
    var alert:Alert?
    var delegate:AlertDetailsHandler?
    
    @IBOutlet weak var conditionPicker: UIPickerView!
    @IBOutlet weak var valueTextView: UITextField!
    
    var done:Bool = false
    override func viewDidLoad() {

        super.viewDidLoad()
        
        if(alert != nil)
        {
        switch alert!.condition
        {
        case .greater: conditionPicker.selectRow(0, inComponent: 0, animated: false);
        case .equal: conditionPicker.selectRow(1, inComponent: 0, animated: false)
        case .less: conditionPicker.selectRow(2, inComponent: 0, animated: false);
        }
            
           valueTextView.text = String(alert!.value)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func cancelPushed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.dismissed()
        }
    }
    @IBAction func donePushed(_ sender: Any) {
        var condition:AlertCondition?
        
        condition = AlertCondition ( rawValue: alertPickerData[conditionPicker.selectedRow(inComponent: 0)].lowercased())
        self.alert = Alert((alert?.rateId)!,condition!, value: Double(valueTextView.text!)!,id: (alert?.id)!)
        
        self.dismiss(animated: true){
            self.delegate?.done(alert: self.alert!)
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return alertPickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return alertPickerData[row]
    }
}
