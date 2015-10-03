//
//  PhotoDataSource.swift
//  Photo Stats
//
//  Created by Matthieu Rouif on 17/09/2015.
//  Copyright © 2015 As-App. All rights reserved.
//

import Foundation
import Photos

public struct DataPoint {
    let startDate: NSDate
    let count: Int
}

class UserPhotoFetcher: NSObject {    

    func mediaCount(start: NSDate, end: NSDate, mediaType: PHAssetMediaType) -> DataPoint {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "creationDate > %@ AND creationDate < %@ AND mediaType == \(mediaType.hashValue)", argumentArray: [start,end])
        let fetchResult = PHAsset.fetchAssetsWithOptions(fetchOptions)
        return DataPoint(startDate: start, count: fetchResult.count)
    }
    
    func mediaCountWithShortDuration(start: NSDate, end: NSDate, mediaType: PHAssetMediaType) -> DataPoint {
        let fetchOptions = PHFetchOptions()
        let timeInterval = NSTimeInterval(5)
        fetchOptions.predicate = NSPredicate(format: "creationDate > %@ AND creationDate < %@ AND duration < \(timeInterval) AND mediaType == \(mediaType.hashValue)", argumentArray: [start,end])
        let fetchResult = PHAsset.fetchAssetsWithOptions(fetchOptions)
        return DataPoint(startDate: start, count: fetchResult.count)
    }

    func arrayOfMonthlyMediaCount(mediaType: PHAssetMediaType) -> [DataPoint] {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssetsWithOptions(fetchOptions)

        //take the first 95% as a start date
        let count = Float(fetchResult.count)
        let firstPosition = Int(count*0.05)
        let firstPhoto = fetchResult.objectAtIndex(firstPosition)
        var firstDate = (firstPhoto.creationDate) ??  NSDate()
        
        let calendar = NSCalendar.currentCalendar()

        //edit first date to 2005
        let components = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: firstDate!)
        // Getting the First and Last date of the month
        firstDate = calendar.dateFromComponents(components)!

        var photoCount: [DataPoint] = []
        let now = NSDate() as NSDate
        
        if let _ = firstDate {
            while firstDate!.timeIntervalSinceDate(now) < 3600*24*30 {
                
                let components = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: firstDate!)
                
                // Getting the First and Last date of the month
                components.day = 1
                let firstDateOfMonth: NSDate = calendar.dateFromComponents(components)!
                
                components.month  += 1
                components.day = 0
                let lastDateOfMonth: NSDate = calendar.dateFromComponents(components)!
                
                photoCount.append(self.mediaCount(firstDateOfMonth, end: lastDateOfMonth, mediaType: mediaType))
                //increment the loop
                components.day = 1
                firstDate = calendar.dateFromComponents(components)!
            }
        }
        photoCount.removeLast()
        return photoCount
    }
    
    func arrayOfMonthlyMediaCountWithShortDuration(mediaType: PHAssetMediaType) -> [DataPoint] {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssetsWithOptions(fetchOptions)
        
        //take the first 95% as a start date
        let count = Float(fetchResult.count)
        let firstPosition = Int(count*0.05)
        let firstPhoto = fetchResult.objectAtIndex(firstPosition)
        var firstDate = (firstPhoto.creationDate) ??  NSDate()
        
        let calendar = NSCalendar.currentCalendar()
        
        //edit first date to 2005
        let components = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: firstDate!)
        // Getting the First and Last date of the month
        firstDate = calendar.dateFromComponents(components)!
        
        var photoCount: [DataPoint] = []
        let now = NSDate() as NSDate
        
        if let _ = firstDate {
            while firstDate!.timeIntervalSinceDate(now) < 3600*24*30 {
                
                let components = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: firstDate!)
                
                // Getting the First and Last date of the month
                components.day = 1
                let firstDateOfMonth: NSDate = calendar.dateFromComponents(components)!
                
                components.month  += 1
                components.day = 0
                let lastDateOfMonth: NSDate = calendar.dateFromComponents(components)!
                
                photoCount.append(self.mediaCountWithShortDuration(firstDateOfMonth, end: lastDateOfMonth, mediaType: mediaType))
                //increment the loop
                components.day = 1
                firstDate = calendar.dateFromComponents(components)!
            }
        }
        photoCount.removeLast()
        return photoCount
    }

}
