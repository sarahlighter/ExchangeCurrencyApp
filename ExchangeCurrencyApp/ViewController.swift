//
//  ViewController.swift
//  ExchangeCurrencyApp
//
//  Created by xinrui wang on 2/7/20.
//  Copyright © 2020 xinrui wang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var txtConvert: UITextField!
    
    @IBOutlet weak var txtInto: UITextField!
    
    @IBOutlet weak var lblCurrency: UILabel!
    
    var currencyTypes = Array<String>()
    
    var pickerView = UIPickerView()
    
    var activeField: UITextField?
    
    var cur1 = "USD"
    var cur2 = "CAD"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllCurrencyType()
        txtConvert.delegate = self
        txtInto.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        txtConvert.inputView = pickerView
        txtInto.inputView = pickerView
    }
    func getAllCurrencyType(){
        let url = "https://api.exchangeratesapi.io/latest"
        
        Alamofire.request(url, method: .get, parameters: nil).responseJSON{(response) in
            
            SwiftSpinner.hide()
            
            if response.result.isSuccess {
                let currencyJSON = JSON(response.result.value!)
                let ratesJSON = JSON(currencyJSON["rates"])
                let baseCurrency = currencyJSON["base"]
                self.currencyTypes = Array(ratesJSON.dictionary!.keys)
                self.currencyTypes.append(baseCurrency.string!)
            }
        }
        
    }
        
    @IBAction func exchange(_ sender: Any) {
        cur1 = txtConvert.text!
        cur2 = txtInto.text!
        getExchangeValue(cur1, cur2)
    }
    
    func getExchangeValue(_ cur1: String, _ cur2: String){
        let url = "https://api.exchangeratesapi.io/latest/?base=\(cur1)"
        SwiftSpinner.show("Getting Currency", animated: true)
        Alamofire.request(url, method: .get, parameters: nil).responseJSON{(response) in
            
            SwiftSpinner.hide()
            
            if response.result.isSuccess {
                let currencyJSON = JSON(response.result.value!)
                let ratesJSON = JSON(currencyJSON["rates"])
                let exchanged = ratesJSON[cur2].floatValue
                let text = "1 \(cur1) = \(exchanged) \(cur2)"
                if(currencyJSON == "" || ratesJSON == ""){
                    self.lblCurrency.text = "Invalid Input"
                } else{
                    self.lblCurrency.text = text
                }
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyTypes[row]
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        return true
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activeField?.text = currencyTypes[row]
        activeField?.resignFirstResponder()
    }
    

}

