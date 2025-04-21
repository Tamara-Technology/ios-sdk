//
//  TamaraWidgetVC.swift
//  Runner
//
//  Created by Thien on 02/06/2023.
//

import Foundation
import UIKit

final class TamaraWidgetVC: UIViewController {
    static var shared = TamaraWidgetVC()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension TamaraWidgetVC {
    func renderWidgetCartPage(language: String, country: String, publicKey: String,
                              amount: Double, completion: @escaping (AnyObject?, Error?, Int) -> Void) -> Void{
        DispatchQueue.main.async {
            let content:NSDictionary = ["script" :self.generateUI(language: language, country: country, publicKey: publicKey, amount: amount, inline: "6"),
                                        "url" : self.generateURL(language: language, country: country, publicKey: publicKey, amount: amount, inline: "6")]
            completion(content , nil, 200)
        }
    }
    
    func renderWidgetProduct(language: String, country: String, publicKey: String,
                             amount: Double, completion: @escaping (AnyObject?, Error?, Int) -> Void) -> Void{
        DispatchQueue.main.async {
            let content:NSDictionary = ["script" :self.generateUI(language: language, country: country, publicKey: publicKey, amount: amount, inline: "2"),
                                        "url" : self.generateURL(language: language, country: country, publicKey: publicKey, amount: amount, inline: "2")]
            completion(content , nil, 200)
        }
    }
    
    func generateUI(language: String, country: String, publicKey: String,
                    amount: Double, inline: String)-> String {
        var srcScript = "https://cdn-sandbox.tamara.co/widget-v2/tamara-widget.js"
        if (!TamaraSDKPayment.shared.isSandbox) {
            srcScript = "https://cdn.tamara.co/widget-v2/tamara-widget.js"
        }
        let amountS = String(format: "%.0f", amount)
        var uI: String = "<script>\n"
        uI += "        window.tamaraWidgetConfig = {\n"
        uI += "            lang: \""+language+"\",\n"
        uI += "            country: \""+country+"\",\n"
        uI += "            publicKey: \""+publicKey+"\"\n"
        uI += "        }\n"
        uI += "      </script>\n"
        uI += "      <script defer type=\"text/javascript\" src=\""+srcScript+"\"></script>\n"
        uI += "\n"
        uI += "      \n"
        uI += "      <tamara-widget type=\"tamara-summary\" config='{\"badgePosition\":\"\",\"showExtraContent\":\"full\",\"hidePayInX\":false}' amount=\""+amountS+"\""
        uI += "inline-type=\""+inline+"\"></tamara-widget>"
        
        return uI
    }
    
    func generateURL(language: String, country: String, publicKey: String,
                     amount: Double, inline: String)-> String {
        let amountS = String(format: "%.0f", amount)
        var url = "https://cdn-sandbox.tamara.co/widget-v2/tamara-widget.html"
        
        if (!TamaraSDKPayment.shared.isSandbox) {
            url = "https://cdn.tamara.co/widget-v2/tamara-widget.html"
        }
        url += "?lang="+language
        url += "&public_key="+publicKey
        url += "&country="+country
        url += "&amount="+amountS
        url += "&inline_type="+inline
        
        return url
    }
}
