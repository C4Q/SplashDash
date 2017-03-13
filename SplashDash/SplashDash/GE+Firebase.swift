//
//  GE+Firebase.swift
//  SplashDash
//
//  Created by Tong Lin on 3/2/17.
//  Copyright © 2017 SHT. All rights reserved.
//

import UIKit
import Firebase

extension GameViewController{
    
    func getRootName() -> String{
        let format = DateFormatter()
        format.dateFormat = "yyyyMMdd"
        return format.string(from: Date())
    }
    
    func fetchGlobalSplash(){
        let linkRef = databaseReference.child(getRootName())
        
        linkRef.observe(FIRDataEventType.childAdded, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary{
                if let coor = SplashCoordinate(value){
                    
                    //draw all splashes parsed from database
                    let splash = SplashOverlay(coor: coor)
                    self.invisibleMapView.addOverlays([splash])
                    self.mapView.addOverlays([splash])
                }
            }
        })
    }
    
    func pushSplashToDatabase(coor: SplashCoordinate){
        let linkRef = databaseReference.child(getRootName()).childByAutoId()
        let data = coor.toData()
        
        linkRef.setValue(data) { (error, _) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            // print("Splash coordinate successfully stored.")
        }
    }
    
    func endRunUpdate(){
        self.previousLocation = nil
        self.timer?.invalidate()
        timer = nil
        
        guard let currentUser = FIRAuth.auth()?.currentUser?.uid,
            currentRunCoordinates.count > 0 else { return }
        
        let linkRef = FIRDatabase.database().reference().child("Users").child(currentUser).child("runs")
        
        let thisRun = Run(allCoordinates: currentRunCoordinates, totalDistance: self.traveledDistanceInMeters, runDuration: self.duration)
        let data = thisRun.toData()
        
        linkRef.childByAutoId().setValue(data) { (error, _) in
            if let error = error {
                print(error.localizedDescription)
            } else{
                print("Current run updated")
                self.currentRunCoordinates = []
                self.traveledDistanceInMeters = 0
                self.duration = 0
                self.fetchCurrentUserData()                
            }
        }
        
    }
    
}
