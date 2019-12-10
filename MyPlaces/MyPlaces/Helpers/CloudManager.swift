//
//  CloudManager.swift
//  MyPlaces
//
//  Created by Станислав Лемешаев on 08.12.2019.
//  Copyright © 2019 Станислав Лемешаев. All rights reserved.
//

import UIKit
import CloudKit
import RealmSwift

class CloudManager {
    
    private static let privateCloudDatabase = CKContainer.default().publicCloudDatabase
    private static var records: [CKRecord] = []
    
    static func saveDataToCloud(place: Place, with image: UIImage, clouser: @escaping(String) -> ()) {
        
        let (image, url) = prepareImageToSaveToCloud(place: place, image: image)
        
        guard let imageAsset = image, let imageURL = url else { return }
        
        let record = CKRecord(recordType: "Place")
        record.setValue(place.placeID, forKey: "placeID")
        record.setValue(place.name, forKey: "name")
        record.setValue(place.location, forKey: "location")
        record.setValue(place.type, forKey: "type")
        record.setValue(place.rating, forKey: "rating")
        record.setValue(imageAsset, forKey: "imageData")
        
        privateCloudDatabase.save(record) { (newRecord, error) in
            if let error = error { print(error); return }
            if let newRecord = newRecord {
                clouser(newRecord.recordID.recordName)
            }
            deleteTempImage(imageURL: imageURL)
        }
    }
    
    static func fetchDataFromCloud(places: Results<Place>, closure: @escaping (Place) -> ()) {
        
        let query = CKQuery(recordType: "Place", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["recordID", "placeID", "name", "location", "type", "rating"]
        queryOperation.resultsLimit = 5
        queryOperation.queuePriority = .veryHigh
        
        queryOperation.recordFetchedBlock = { record in
            
            self.records.append(record)
            let newPlace = Place(record: record)
            
            DispatchQueue.main.async {
                if newCloudRecordIsAvailable(places: places, placeID: newPlace.placeID) {
                    closure(newPlace)
                }
            }
        }
        
        queryOperation.queryCompletionBlock = { cursor, error in
            if let error = error { print(error.localizedDescription); return }
            guard let cursor = cursor else { return }
            
            let secondQueryOperation = CKQueryOperation(cursor: cursor)
            
            secondQueryOperation.recordFetchedBlock = { record in
                self.records.append(record)
                let newPlace = Place(record: record)
                
                DispatchQueue.main.async {
                    if newCloudRecordIsAvailable(places: places, placeID: newPlace.placeID) {
                        closure(newPlace)
                    }
                }
            }
            
            secondQueryOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
            privateCloudDatabase.add(secondQueryOperation)
        }
        
        privateCloudDatabase.add(queryOperation)
        
    }
    
    static func updateCloudData(place: Place, with image: UIImage) {
        
        let recordID = CKRecord.ID(recordName: place.recordID)
        
        let (image, url) = prepareImageToSaveToCloud(place: place, image: image)
        guard let imageAsset = image, let imageURL = url else { return }
        
        privateCloudDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let record = record, error == nil {
                DispatchQueue.main.async {
                    record.setValue(place.name, forKey: "name")
                    record.setValue(place.location, forKey: "location")
                    record.setValue(place.type, forKey: "type")
                    record.setValue(place.rating, forKey: "rating")
                    record.setValue(imageAsset, forKey: "imageData")
                    
                    privateCloudDatabase.save(record, completionHandler: { (_, error) in
                        if let error = error {
                            print(error.localizedDescription); return
                        }
                        deleteTempImage(imageURL: imageURL)
                    })
                }
            }
        }
    }
    
    static func getImageFromCloud(place: Place, closure: @escaping (Data?) -> ()) {
        
        records.forEach { (record) in
            if place.recordID == record.recordID.recordName {
                let fetchRecordOperation = CKFetchRecordsOperation(recordIDs: [record.recordID])
                fetchRecordOperation.desiredKeys = ["imageData"]
                fetchRecordOperation.queuePriority = .veryHigh
                
                fetchRecordOperation.perRecordCompletionBlock = { record, _, error in
                    guard error == nil else { return }
                    guard let record = record else { return }
                    guard let possibleImage = record.value(forKey: "imageData") as? CKAsset else { return }
                    guard let imageData = try? Data(contentsOf: possibleImage.fileURL!) else { return }
                    
                    DispatchQueue.main.async {
                        closure(imageData)
                    }
                }
                privateCloudDatabase.add(fetchRecordOperation)
            }
        }
    }
    
    // MARK: Private Methods
    private static func prepareImageToSaveToCloud(place: Place, image: UIImage) -> (CKAsset?, URL?) {
        
        let scale = image.size.width > 1080 ? 1080 / image.size.width : 1
        let scaleImage = UIImage(data: image.pngData()!, scale: scale)
        let imageFilePath = NSTemporaryDirectory() + place.name
        let imageURL = URL(fileURLWithPath: imageFilePath)
        
        guard let dataToPath = scaleImage?.jpegData(compressionQuality: 1) else { return (nil, nil) }
        
        do {
            try dataToPath.write(to: imageURL, options: .atomic)
        } catch  {
            print(error.localizedDescription)
        }
        
        let imageAsset = CKAsset(fileURL: imageURL)
        
        return (imageAsset, imageURL)
    }
    
    static private func deleteTempImage(imageURL: URL) {
        do {
            try FileManager.default.removeItem(at: imageURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private static func newCloudRecordIsAvailable(places: Results<Place>, placeID: String) -> Bool {
        
        
        for place in places {
            if place.placeID == placeID {
                return false
            }
        }
        return true
    }
    
}
