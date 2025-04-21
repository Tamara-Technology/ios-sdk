//
//  ExampleView.swift
//  Example
//
//  Created by TruongThien on 5/8/23.
//  Copyright © 2023 Tamara. All rights reserved.
//

import SwiftUI
import TamaraSDK

struct MainView: View {
    @EnvironmentObject var appState: AppState
    var scriptCartPage: String = ""
    var scriptProduct: String = ""
    @State private var isAuthenticating = false
    @State private var isIniting = false
    @State private var isInitSuccess = false
    @State private var isShow = false
    @State private var isError = false
    @State private var isErrorMessage = false
    @State private var country = "SA"
    @State private var amount = "100"
    @State private var currency = "SAR"
    @State private var phone = ""
    @State private var isVip = "false"
    @State private var dataResult = ""
    @State private var dataError = ""
    @State private var token = MERCHANT_TOKEN
    @State private var apiUrl = HOST
    @State private var publishKey = WebViewParagrams.publicKey.rawValue
    @State private var pushUrl = "https://example.co/pushnotification"
    @State private var notificationToken = ""
    @State private var isSandbox = "true"
    
    init(cartPage: Binding<[String: String]>, productPage: Binding<[String: String]>) {
        self.scriptCartPage = cartPage.wrappedValue["script"] ?? ""
        self.scriptProduct = productPage.wrappedValue["script"] ?? ""
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        VStack {
            Text("Tamara Checkout Example App")
            
            if #available(iOS 15.0, *) {
                RoundedButton(label: "Init", buttonAction: {
                    isIniting.toggle()
                })
                .padding(.top, 20).alert("Init", isPresented: $isIniting) {
                    TextField("token", text:$token)
                    TextField("apiUrl", text: $apiUrl)
                    TextField("publishKey", text: $publishKey)
                    TextField("pushUrl", text: $pushUrl)
                    TextField("notificationToken", text: $notificationToken)
                    TextField("isSandbox", text: $isSandbox)
                    Button("OK", action: initValue)
                } message: {
                }.alert("Init success", isPresented: $isInitSuccess) {
                    Button("OK", role: .cancel) { }
                }
            } else {
                // Fallback on earlier versions
            }
            
            RoundedButton(label: "Test create order", buttonAction: {
                self.appState.currentPage = .Cart
            })
                .padding(.top, 20)
            
            RoundedButton(label: "Test create order from url", buttonAction: {
                let merchantUrl = TamaraMerchantURL(
                    success: "tamara://checkout/success",
                    failure: "tamara://checkout/failure",
                    cancel: "tamara://checkout/cancel",
                    notification: "https://example.com/checkout/notification"
                )
                
                DispatchQueue.main.async {
                    self.appState.isLoading = false
//                    self.appState.viewModel = TamaraSDKCheckoutSwiftUIViewModel(url: url, merchantURL: merchantUrl)
                    self.appState.currentPage = AppPages.Test
                }
//                self.appState.currentPage = .Cart
            })
                .padding(.top, 20)
            if #available(iOS 15.0, *) {
                RoundedButton(label: "Check payment options") {
                    isAuthenticating.toggle()
                }.padding(.top, 20)
                .alert("Check payment options", isPresented: $isAuthenticating) {
                    TextField("country(required)", text: $country)
                        .textInputAutocapitalization(.never)
                    TextField("amount (required)", text: $amount)
                    TextField("currency (required)", text: $currency)
                    TextField("PhoneNumber", text: $phone)
                    TextField("isVip", text: $isVip)
                    Button("OK", action: authenticate)
                    Button("Cancel", role: .cancel) { }
                } message: {
                }.popover(isPresented: self.$isError,
                           attachmentAnchor: .rect(.rect(CGRect(x: 0, y: 20,
                                                  width: 160, height: 100))),
                           arrowEdge: .top,
                           content: {
                      Text("Input required")
                          .padding()
                }).alert(dataResult, isPresented: $isShow) {
                    Button("OK", role: .cancel) { }
                }
                .alert(dataError, isPresented: $isErrorMessage) {
                    Button("OK", role: .cancel) { }
                }
            } else {
                // Fallback on earlier versions
            }
            
            RoundedButton(label: "Tamara Checkout Widget", buttonAction: {
                self.appState.currentPage = .CartPage
            })
                .padding(.top, 20)
            
            if !scriptCartPage.isEmpty {
                WebViewWrapper(html: scriptCartPage)
                    .frame(height: 350)
                    .padding(.top, 20)
            }
            
            RoundedButton(label: "Product Widget", buttonAction: {
                 self.appState.currentPage = .Product
             })
                 .padding(.top, 20)
 
             if !scriptProduct.isEmpty {
                 WebViewWrapper(html: scriptProduct)
                     .frame(height: 200)
                     .padding(.top, 20)
             }
            
        }
        .navigationBarHidden(true)
        .navigationBarItems(trailing: HStack{})
    }
    func initValue() {
        let tamara = TamaraSDKPayment()
        tamara.initialize(token: token, apiUrl: apiUrl, pushUrl: pushUrl, publishKey: publishKey, notificationToken: notificationToken, isSandbox: Bool(isSandbox) ?? true)
        isInitSuccess = true
    }
    func authenticate() {
        isError = false
        if !country.isEmpty && !amount.isEmpty && !currency.isEmpty {
                let tamara = TamaraSDKPayment()
                self.appState.isLoading = true
                let json = "{\n" +
                            "\"country\": \"\(country)\",\n" +
                            "\"order_value\": {\n" +
                            "\"amount\": \(Double(amount)!),\n" +
                            "\"currency\": \"\(currency)\"\n" +
                            "},\n" +
                            "\"phone_number\": \"\(phone)\",\n" +
                            "\"is_vip\": \(Bool(isVip)!)\n" +
            "}"
                tamara.checkPaymentOptions(jsonData: json) { result in
                    do {
                                    self.appState.isLoading = false
                                    switch result {
                                    case .success(let response):
                                        let jsonEncoder = JSONEncoder()
                                        let decoder = JSONDecoder()
                                        let result1 = try decoder.decode(PaymentOptionsResponse.self, from: jsonEncoder.encode(response))
                                        
                                        dataResult = String(decoding: try jsonEncoder.encode(response), as: UTF8.self)
                                        print(result1)
                                        isShow = true
                                        break
                                    case.failure(let error):
                                        isErrorMessage = true
                                        dataError = error.localizedDescription
                                        print(error)
                                        break
                                    }
                                } catch {
                                    print(error)
                                }
                }
            } else {
                isError = true
            }
    }
    
    func calculateTotal() {
        
    }
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
