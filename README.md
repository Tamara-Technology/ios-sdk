# IOS SDK

This project including 2 modules:
* SDK Module: Setup Tamara SDK
* Example app: Simple online shopping app which uses Tamara SDK for payment

# Usage

The SDK provides these functionalities:

* WebKit webview handler to display Tamara checkout page on your application.
* Tamara "Learn More" View. So you can show short descriptions about Tamara easily.

This is the general workflow for using tamara on your application:

![image](https://github.com/tamara-solution/ios-sdk/assets/121469787/fedcdf6c-9f5c-42aa-bf52-e4e79c7965ba)


So, assuming you already called our checkout API, and got `checkout_url`, let's do some quick coding to get it done.

## 1. Init checkout data
As in API document (https://docs.tamara.co/#tag/Checkout/paths/~1checkout/post), you need to provide some URLs for the checkout flow. For mobile app, you need to also declare the `success` and `failure` URLs, which exactly the same with what your backend sent to our API, so the WebView in SDK can detect whether checkout is success or failed.

```swift
let merchantUrl = TamaraMerchantURL(
    success: "tamara://checkout/success",
    failure: "tamara://checkout/failure",
    cancel: "tamara://checkout/cancel",
    notification: "tamara://checkout/notification"
)
```

Then init the model for checkout view. Params is the `checkoutUrl` you received from backend, and `merchantUrl` you created above.

```swift
let viewModel = TamaraSDKCheckoutViewModel(url: checkoutURL, merchantURL: merchantUrl)
```

Note: In case you want to create order from iOS client, not going through your backend, then you might interest in this document [Create order using iOS Client](/ORDER.md).


## 2. Create webview and handle callback (success / failure)
### 1. In SwiftUI 

```swift
SDKViewController(url: appState.viewModel.url,
                  merchantUrl: appState.viewModel.merchantURL,
                  delegate: SDKViewController.Delegate (
                    success: {
                        //Handle Success
                        appState.orderSuccessed = true
                        appState.currentPage = .Success
                    }, failure: {
                        //Handle Failed
                        appState.orderSuccessed = false
                        appState.currentPage = .Success
                    }, cancel: {
                        //Handle Cancel
                        appState.currentPage = .Info
                    }, notification: {
                        //Handle Notification
                    })
)
```
### 2. In UIKit 
```swift
private var tamaraSDK: TamaraSDKCheckout!
```

```swift

self.tamaraSDK = TamaraSDKCheckout(url: item.checkoutUrl, merchantURL: merchantUrl, webView: nil)
self.tamaraSDK.delegate = self
self.present(self.tamaraSDK, animated: true, completion: nil)

```
Delegate Handle

```swift
//Delegate handle action
extension UIKitSDKViewController: TamaraCheckoutDelegate {
    func onSuccessfull() {
    sdkView.dismiss(animated: true) {
            //success handle
        }
    }
    
    func onFailured() {
        tamaraSDK.dismiss(animated: true) {
            //error handle
        }
    }
    
    func onCancel() {
        tamaraSDK.dismiss(animated: true) {
            //cancel handle
        }
    }
    
    func onNotification() {
        tamaraSDK.dismiss(animated: true) {
            //notification handle
        }
    }
}
```

## 3. Add `About Tamara` modal view (Deprecated) 

To make customers understand what is `tamara` and how it works, we also provide this modal view so you can use to show it whenever, wherever you want in your application.

```swift
let vc = TamaraLearnMorePopup()
self.present(vc, animated: true, completion: nil)
```
