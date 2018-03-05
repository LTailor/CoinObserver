//
//  AlertManager.swift
//  CoinObserver
//
//  Created by Dzhambulat Khasayev on 24.01.18.
//  Copyright © 2018 ReseaSoft. All rights reserved.
//

import Foundation
import UserNotifications

enum AlertCondition:String
{
    case greater
    case equal
    case less
}

class Alert:NSObject,NSCoding
{
    var rateId:Int
    var condition:AlertCondition
    var id:Int
    var value:Double
    
    init(_ rateId:Int,_ condition:AlertCondition,value:Double,id:Int)
    {
        self.rateId = rateId
        self.condition = condition
        self.value = value
        self.id = id
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.rateId, forKey: "rateId")
        aCoder.encode(self.condition.rawValue, forKey: "condition")
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.value, forKey: "value")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let id = aDecoder.decodeInteger(forKey: "id")
        let rateId = aDecoder.decodeInteger(forKey: "rateId")
        let condition = AlertCondition(rawValue:aDecoder.decodeObject(forKey: "condition") as! String)
        let value = aDecoder.decodeDouble(forKey: "value")
        
        /*guard storedTitle != nil && storedURL != nil else {
            return nil
        }*/
        
        self.init(rateId,condition!,value:value,id:id)
        
        
    }

}

class AlertManager
{
    static let instance = AlertManager(isLoad: true)
    
    var alerts:[Int:[Alert]]
    var id:Int = 0
    
    init(isLoad load:Bool)
    {
        alerts = [Int:[Alert]]()
        if(load)
        {
            self.load()
        }
        CoinInfoInteractor.instance.addDelegate(checkAlerts)
    }
    
    func feedFilePath() -> String {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let filePath = paths[0].appendingPathComponent("alertsFile1.plist")
        return filePath.path
    }
    
    func save() -> Bool {
        let success = NSKeyedArchiver.archiveRootObject(alerts, toFile: feedFilePath())
        assert(success, "failed to write archive")
        return success
    }
    
    func load() {
        let path = feedFilePath()
        let unarchivedObject = NSKeyedUnarchiver.unarchiveObject(withFile: path)
        if (unarchivedObject != nil)
        {
            alerts = unarchivedObject as! [Int:[Alert]]
        }
    }
    

    func updateAlert(_ alert:Alert) -> Int
    {
        var rateAlerts = alerts[alert.rateId]
        if(rateAlerts==nil)
        {
            alerts[alert.rateId] = []
            rateAlerts = alerts[alert.rateId]!
        }
        
        let alertId = alert.id ?? 0
        
        if alertId != 0
        {
            let alertIndex = rateAlerts?.index(where:{(item)->Bool in
                item.id == alert.id
            })
            
            if(alertIndex != nil)
            {
                rateAlerts?[alertIndex!] = alert
                alerts[alert.rateId] = rateAlerts
                self.save()
            }
        }
        else
        {
            id+=1
            alert.id = id
            rateAlerts?.append(alert)
            alerts[alert.rateId] = rateAlerts
            self.save()
        }
        
        
        return alertId
    }
    
    func removeAlert(id:Int,rateId:Int)
    {
        if var rateAlerts = alerts[rateId]
        {
            let alertIndex = rateAlerts.index(where:{(item)->Bool in
                item.id == id
            })
            
            if (alertIndex != nil)
            {
                rateAlerts.remove(at: alertIndex!)
                alerts[rateId] = rateAlerts
                self.save()
            }
        }
    }
    
    func checkAlerts(_ coinsInfo:[Coin]?)->Void
    {
        for ci in coinsInfo!
        {
            if let rateAlerts = alerts[ci.id]
            {
            for ra in rateAlerts
            {
                switch ra.condition
                {
                case .greater:
                    if (ci.price > ra.value)
                    {
                        showAlert(ci.name, .greater, ra.value)
                    }
                    break
                case .less:
                    if (ci.price < ra.value)
                    {
                        showAlert(ci.name, .greater, ra.value)
                    }
                    break
                case .equal:
                    if (ci.price == ra.value)
                    {
                        showAlert(ci.name, .greater, ra.value)
                    }
                    break
                }
            }
            }
        }
    }
    
    private func showAlert(_ rateName:String, _ condition:AlertCondition,_ value:Double)
    {
        let content = UNMutableNotificationContent()
        content.title = rateName
        content.subtitle = "Price change"
        switch (condition)
        {
        case .greater:
            content.body = "The price is greater then " + String(value)
            break
        case .less:
            content.body = "The price is less then " + String(value)
            break
        case .equal:
            content.body = "The price is equal to " + String(value)
            break
        }

        content.badge = 1
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "rateAlert"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    func getAlert(rateId:Int, alertId:Int) -> Alert?
    {
        var rateAlerts = alerts[rateId]
        if rateAlerts == nil
        {
            return nil
        }
        
        let alertIndex = rateAlerts?.index(where:{(item)->Bool in
            item.id == alertId
        })
        
        if(alertIndex != nil)
        {
            return rateAlerts![alertIndex!]
        }
        
        return nil
    }
    
    func getAlerts(_ rateId:Int)->[Alert]?
    {
        return alerts[rateId]
    }
}
