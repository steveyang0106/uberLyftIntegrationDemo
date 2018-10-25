//
//  ViewController.swift
//  uberIntegrationDemo
//
//  Created by mobility on 10/17/18.
//  Copyright © 2018 mobility. All rights reserved.
//

import UIKit
import UberCore
import LyftSDK
import CoreLocation
import UberRides

class ViewController: UIViewController {

    @IBOutlet weak var uberBtn: UIButton!
    @IBOutlet weak var lyftBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UberRidesSDKDemo()
        
        //lyftApiCall()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func UberRidesSDKDemo(){
        let builder = RideParametersBuilder()
        let pickupLocation = CLLocation(latitude: 37.787654, longitude: -122.402760)
        let dropoffLocation = CLLocation(latitude: 37.775200, longitude: -122.417587)
        builder.pickupLocation = pickupLocation
        builder.dropoffLocation = dropoffLocation
        builder.dropoffNickname = "Somewhere"
        builder.dropoffAddress = "123 Fake St."
        let rideParameters = builder.build()
        let button = RideRequestButton(rideParameters: rideParameters)
        view.addSubview(button)
    }
    
    func uberUniversalLinkDemo(){
        let builder = RideParametersBuilder()
        let pickupLocation = CLLocation(latitude: 37.787654, longitude: -122.402760)
        let dropoffLocation = CLLocation(latitude: 37.775200, longitude: -122.417587)
        builder.pickupLocation = pickupLocation
        builder.dropoffLocation = dropoffLocation
        builder.dropoffNickname = "UberHQ"
        builder.dropoffAddress = "1455 Market Street, San Francisco, California"
        let rideParameters = builder.build()
        
        let deeplink = RequestDeeplink(rideParameters: rideParameters, fallbackType: .mobileWeb)
        deeplink.execute()
    }
    
    func lyftApiCall(){
        let pickup = CLLocationCoordinate2D(latitude: 42.265570, longitude: -83.387391)
        let destination = CLLocationCoordinate2D(latitude: 42.253737, longitude: -83.211945)

        LyftAPI.rideTypes(at: pickup) { result in
            result.value?.forEach { rideType in
                print(rideType.displayName)
            }
        }
        
        LyftAPI.ETAs(to: destination) { result in
            result.value?.forEach { eta in
                print("ETA for \(eta.rideKind.rawValue): \(eta.minutes) min")
            }
        }
        
        LyftAPI.costEstimates(from: pickup, to: destination, rideKind: .Standard) { result in
            result.value?.forEach { costEstimate in
                print("Min: \(costEstimate.estimate!.minEstimate.amount)$")
                print("Max: \(costEstimate.estimate!.maxEstimate.amount)$")
                print("Distance: \(costEstimate.estimate!.distanceMiles) miles")
                print("Duration: \(costEstimate.estimate!.durationSeconds/60) minutes")
            }
        }
        

    }
    
    @IBAction func uberClicked(_ sender: Any) {
        uberUniversalLinkDemo()
//        if isInstalledOf(app: "uber") {
//            open(scheme: "uber://?action=setPickup&client_id=7r6zjXf5e1p4nqYkX17d9R44estKs-na&product_id=a12ab23b-66f0-4028-9bb9-856dbcfdbbc7&pickup[formatted_address]=5874%20Newberry%20Street%2C%20Romulus%2C%20MI%2C%20USA&pickup[latitude]=42.265570&pickup[longitude]=-83.387391&dropoff[formatted_address]=15609%20Regina%20Avenue%2C%20Allen%20Park%2C%20MI%2C%20USA&dropoff[latitude]=42.253737&dropoff[longitude]=-83.211945")
//        } else {
//            open(scheme: "https://m.uber.com/ul/")
//        }
    }
    
    @IBAction func lyftClicked(_ sender: Any) {
        if isInstalledOf(app: "lyft") {
            open(scheme: "lyft://ridetype?id=lyft&pickup[latitude]=42.265570&pickup[longitude]=-83.387391&destination[latitude]=42.253737&destination[longitude]=-83.211945")
        } else {
            open(scheme: "https://www.lyft.com/signup/SDKSIGNUP?clientId=IcEuyAmFO7Gp&sdkName=iOS_direct")
        }
    }
    
    @IBAction func callUberApi(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.login(requestedScopes:[.request], presentingViewController: self, completion: { accessToken, error in
            if error != nil {
                print(error?.localizedDescription)
                print(error?.code)
            }else{
                print(accessToken)
            }
            // Completion block. If accessToken is non-nil, you’re good to go
            // Otherwise, error.code corresponds to the RidesAuthenticationErrorType that occured
        })
    }
    
    
    func isInstalledOf(app: String) -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "\(app)://")!)
    }

    
    func open(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    @objc func openURL(_ url: URL){
        return
    }
    
    func launchApp(){
        var responder: UIResponder? = self as UIResponder
        let selector = #selector(openURL(_:))
        
        let urlStr = "uber://?action=setPickup&client_id=7r6zjXf5e1p4nqYkX17d9R44estKs-na&product_id=a12ab23b-66f0-4028-9bb9-856dbcfdbbc7&pickup[formatted_address]=5874%20Newberry%20Street%2C%20Romulus%2C%20MI%2C%20USA&pickup[latitude]=42.265570&pickup[longitude]=-83.387391&dropoff[formatted_address]=15609%20Regina%20Avenue%2C%20Allen%20Park%2C%20MI%2C%20USA&dropoff[latitude]=42.253737&dropoff[longitude]=-83.211945"
        
        while responder != nil {
            if responder!.responds(to: selector) && responder != self {
                responder!.perform(selector, with: URL(string: urlStr))
            }
            responder = responder?.next
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}



