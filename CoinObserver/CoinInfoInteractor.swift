//
//  CoinInfoInteractor.swift
//  CoinObserver
//
//  Created by Dzhambulat Khasayev on 13.01.18.
//  Copyright © 2018 ReseaSoft. All rights reserved.
//

import Foundation

class Coin
{
    var name:String
    var price:Double
    var id:Int
    init(name:String, id:Int) {
        self.name = name
        self.id = id
        price = 0.0
    }
}

struct RateInfo
{
    var firstName:String
    var secondName:String
}

class CoinInfoInteractor
{
    static let instance = CoinInfoInteractor("https://api.cryptonator.com/api/ticker/btc-usd",rates:[RateInfo(firstName: "btc",secondName: "usd"),RateInfo(firstName: "eth",secondName: "usd"),RateInfo(firstName: "xrp",secondName: "usd")])
    var urls:String
    
    var timer:DispatchSourceTimer?
    let mainUrl = "https://api.cryptonator.com/api/ticker/"
    var coinNames:[String]
    var coinsInfo:[Coin]=[]
    var delegates:[(_ coinsInfo:[Coin]?)->Void]?
    var rates:[RateInfo]
    
    init(_ url:String, rates:[RateInfo])
    {
        urls = url
        coinNames = ["btc-usd"]
        delegates = []
        self.rates = rates
        var id = 1
        for r in rates
        {
            coinsInfo.append(Coin(name: r.firstName.uppercased()+"/"+r.secondName.uppercased(), id:id))
            id+=1
        }
    }
    
    func addDelegate(_ delegate:@escaping (_ coinsInfo:[Coin]?)->Void)
    {
        delegates?.append(delegate)
    }
    
    func callDelegates()
    {
        if(delegates==nil)
        {
            return
        }
    
        for d in (delegates)!{
            DispatchQueue.main.async {
                d(self.coinsInfo)
            }
        }
    }
    
    func getExcnhageRate()
    {
        let dispatch_group = DispatchGroup()
        var urls:[URL] = []
        
        for i in 0..<rates.count
        {
            dispatch_group.enter()
            urls.append(URL(string:mainUrl+rates[i].firstName+"-"+rates[i].secondName)!)
            let task = URLSession.shared.dataTask(with: urls[i]) {(data, response, error) in
                
                guard error == nil else {
                    print("returning error")
                    return
                }
                
                guard let content = data else {
                    print("not returning data")
                    return
                }
                
                
                guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                    print("Not containing JSON")
                    return
                }
                
                var result = ""
                if let array = json["ticker"]  {
                    var a = array as? [String:String]
                    result = (a?["price"])!
                    self.coinsInfo[i].price = Double(result)!
                }
                dispatch_group.leave()
                
            }
            
            task.resume()
        }
        
        dispatch_group.wait()
        
    }
    func start()
    {
        timer = DispatchSource.makeTimerSource()
        timer?.scheduleRepeating(deadline: .now(), interval: .seconds(5))
        timer?.setEventHandler(handler: { [weak self] in
            self?.getExcnhageRate()
            self?.callDelegates()
        })
        timer?.resume()
    }
    
}
