//
//  AddressView.swift
//  Example
//
//  Created by Chuong Dang on 4/25/20.
//  Copyright © 2020 Tamara. All rights reserved.
//

import SwiftUI
import TamaraSDK

struct InfoView : View {
    
    @EnvironmentObject var appState: AppState
    var body: some View {
        List {
            LabelTextView(label: "First Name", placeHolder: "Mona", text: self.$appState.shippingAddress.firstName)
            LabelTextView(label: "Last Name", placeHolder: "Lisa", text: self.$appState.shippingAddress.lastName)
            LabelTextView(label: "Address Line 1", placeHolder: "3764 Al Urubah Rd", text: self.$appState.shippingAddress.line1)
            LabelTextView(label: "Address Line 2", placeHolder: "Block A", text: self.$appState.shippingAddress.line2)
            LabelTextView(label: "Region", placeHolder: "As Sulimaniyah", text: self.$appState.shippingAddress.region)
            LabelTextView(label: "City", placeHolder: "Riyadh", text: self.$appState.shippingAddress.city)
            LabelTextView(label: "Phone Number", placeHolder: "502223333", text: self.$appState.shippingAddress.phoneNumber)
            RoundedButton(label: "Checkout", buttonAction: self.checkout)
                .padding(.top, 20)
        }
        .buttonStyle(BorderlessButtonStyle())
        .padding(.horizontal, 5)
        .navigationBarTitle("Customer Info")
        .navigationBarBackButtonHidden(true)
    }
    
    func checkout() {
        let tamara = TamaraSDKPayment()
        self.appState.isLoading = true
        tamara.initialize(token: MERCHANT_TOKEN, apiUrl: HOST, pushUrl: "https://example.co/pushnotification", publishKey: WebViewParagrams.publicKey.rawValue, notificationToken: NOTIFICATION_TOKEN, isSandbox: true)
        tamara.createOrder(orderReferenceId: "A352BB0A59044C77928A7551A1EA566B", description: "String")
        tamara.setCurrency(newCurrency: "AED")
        tamara.setCountry(countryCode: "AE", currency: "AED")
        tamara.setInstalments(instalments: 1)
        tamara.setPlatform(platform: "Ios")
        tamara.setLocale(locale: "en-US")
        let riskValidate = tamara.setRiskAssessment(jsonData: self.$appState.riskAssessment.wrappedValue)
        if (!riskValidate) {
            //check again json
        }
        tamara.setPaymentType(paymentType: "PAY_BY_INSTALMENTS")
        tamara.setCustomerInfo(firstName: "Mona", lastName: "Lisa", phoneNumber: "502223353", email: "user1@gmail.com")
        
        tamara.clearItem()
        
        tamara.setAdditionalData(jsonData: "{\"custom_field1\": 42, \"custom_field2\": \"value2\" }")
        
        tamara.addCustomFieldsAdditionalData(jsonData: "{\"custom_field1\": 45, \"custom_field2\": \"value2\" }")
        
        tamara.addItem(name: "Lego City 8601", referenceId:  "123456_item", sku: "SA-12436", type: "Digital", unitPrice: 50.0, tax: 10.0, discount: 25.0, quantity: 1)
        
        tamara.addItem(name: "Batman", referenceId:  "123457_item", sku: "SA-12437", type: "Digital", unitPrice: 25.0, tax: 10.0, discount: 5.0, quantity: 1)
        
        tamara.addItem(name: "Spider man", referenceId:  "123458_item", sku: "SA-12438", type: "Digital", unitPrice: 25.0, tax: 10.0, discount: 5.0, quantity: 1)
        
        tamara.addItem(name: "Thor", referenceId:  "123459_item", sku: "SA-12439", type: "Digital", unitPrice: 100.0, tax: 10.0, discount: 25.0, quantity: 1)
        
        tamara.addItem(name: "Iron man", referenceId:  "123460_item", sku: "SA-12460", type: "Digital", unitPrice: 500.0, tax: 10.0, discount: 0.0, quantity: 1)
        tamara.setShippingAmount(amount: 20.0)
        tamara.setDiscount(amount: 100.0, name: "Launch event's discount")

        tamara.setShippingAddress(firstName: "Mona", lastName: "Lisa", phoneNumber: "502223337", addressLine1: "3764 Al Urubah Rd", addressLine2: "", country: "SA", region: "As Sulimaniyah", city: "Riyadh")
        
        tamara.setBillingAddress(firstName: "Mona", lastName: "Lisa", phoneNumber: "502223337", addressLine1: "3764 Al Urubah Rd", addressLine2: "", country: "SA", region: "As Sulimaniyah", city: "Riyadh")
        
        tamara.startPayment() { result in
            do {
                            self.appState.isLoading = false
                            switch result {
                            case .success(let response):
                                let jsonEncoder = JSONEncoder()
                                let decoder = JSONDecoder()
                                let checkout = try decoder.decode(TamaraCheckoutResponse.self, from: jsonEncoder.encode(response))
                                let strUrl = checkout.checkoutUrl
                                let merchantUrl = TamaraMerchantURL(
                                    success: "tamara://checkout/success",
                                    failure: "tamara://checkout/failure",
                                    cancel: "tamara://checkout/cancel",
                                    notification: "https://example.com/checkout/notification"
                                )
                                if strUrl != "" {
                                    self.appState.viewModel = TamaraSDKCheckoutSwiftUIViewModel(url: strUrl, merchantURL: merchantUrl)
                                    self.appState.currentPage = AppPages.Checkout
                                }
                            case .failure(let error):
                                print(error)
                                break
                            }
                        } catch {
                            print(error)
                        }
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
