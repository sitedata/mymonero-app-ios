//
//  PersistableObject.swift
//  MyMonero
//
//  Created by Paul Shapiro on 5/19/17.
//  Copyright © 2017 MyMonero. All rights reserved.
//

import Foundation
import RNCryptor
//
class PersistableObject
{
	var _id: String?
	var insertedAt_date: Date?
	//
	var didFailToInitialize_flag: Bool?
	var didFailToBoot_flag: Bool?
	var didFailToBoot_errStr: String?
	//
	enum NotificationNames: String
	{
		case willBeDeleted = "PersistableObject_NotificationNames_willBeDeleted"
		//
		var notificationName: NSNotification.Name
		{
			return NSNotification.Name(self.rawValue)
		}
	}
	//
	func collectionName() -> String
	{
		assert(false, "You must override PersistableObject/collectionName")
		return ""
	}
	func new_encrypted_dictRepresentationData(withPassword password: PasswordController.Password) throws -> Data
	{
		let dict = self.new_dictRepresentation() // plaintext
		let plaintextData =  try JSONSerialization.data(
			withJSONObject: dict,
			options: []
		)
		let encryptedData = RNCryptor.encrypt(data: plaintextData, withPassword: password)
		//
		return encryptedData
	}
	func new_dictRepresentation() -> DocumentPersister.DocumentJSON
	{
		var dict: [String: Any] = [:]
		dict["_id"] = self._id
		if self.insertedAt_date != nil {
			dict["insertedAt_date"] = self.insertedAt_date!.timeIntervalSince1970
		}
		//
		// Note: Override this method and add data you would like encrypted – but call on super 
		return dict as DocumentPersister.DocumentJSON
	}
	//
	required init()
	{ // placed here for inserts
	}
	required init?(withPlaintextDictRepresentation dictRepresentation: DocumentPersister.DocumentJSON) throws
	{
		self._id = dictRepresentation["_id"] as? String
		if let json__insertedAt_date = dictRepresentation["insertedAt_date"] {
			guard let insertedAt_date_timeInterval = json__insertedAt_date as? TimeInterval else {
				assert(false, "json__insertedAt_date not a TimeInterval")
				return nil
			}
			self.insertedAt_date = Date(timeIntervalSince1970: insertedAt_date_timeInterval)
		}
	}
	//
	// Lifecycle - Deinit
	deinit
	{
		DDLog.TearingDown("Persistence", "Tearing down a \(self).")
	}
	//
	// Accessors - Persistence state
	var shouldInsertNotUpdate: Bool
	{
		return self._id == nil
	}
	//
	// Imperatives - Saving
	func saveToDisk() -> String? // -> err_str?
	{
		if self.shouldInsertNotUpdate == true {
			return self._saveToDisk_insert()
		}
		return self._saveToDisk_update()
	}
	// For these, we presume consumers/parents/instantiators have only created this wallet if they have gotten the password
	func _saveToDisk_insert() -> String? // -> err_str?
	{
		assert(self._id == nil, "non-nil _id in \(#function)")
		// only generate _id here after checking shouldInsertNotUpdate since that relies on _id
		self._id = DocumentPersister.new_DocumentId() // generating a new UUID
		// and since we know this is an insertion, let's any other initial centralizable data
		self.insertedAt_date = Date()
		// and now that those values have been placed, we can generate the dictRepresentation
		do {
			let data = try self.new_encrypted_dictRepresentationData(withPassword: PasswordController.shared.password!)
			let err_str = DocumentPersister.shared.Write(
				documentFileWithData: data,
				withId: self._id!,
				toCollectionNamed: self.collectionName()
			)
			if err_str != nil {
				DDLog.Error("Persistence", "Error while saving new object: \(err_str!)")
			} else {
				DDLog.Done("Persistence", "Saved new \(self).")
			}
			return err_str
		} catch let e {
			let err_str = e.localizedDescription
			DDLog.Error("Persistence", "Caught error while saving new object: \(err_str)")
			return err_str // TODO? possibly change saveToDisk() -> String? to saveToDisk() throws
		}
	}
	func _saveToDisk_update() -> String?
	{
		assert(self._id != nil, "nil _id in \(#function)")
		do {
			let data = try self.new_encrypted_dictRepresentationData(withPassword: PasswordController.shared.password!)
			let err_str = DocumentPersister.shared.Write(
				documentFileWithData: data,
				withId: self._id!,
				toCollectionNamed: self.collectionName()
			)
			if err_str != nil {
				DDLog.Error("Persistence", "Error while saving update to object: \(err_str!)")
			} else {
				DDLog.Done("Persistence", "Saved update to \(self).")
			}
			return err_str
		} catch let e {
			let err_str = e.localizedDescription
			DDLog.Error("Persistence", "Caught error while saving update to object: \(err_str)")
			return err_str // TODO? possibly change saveToDisk() -> String? to saveToDisk() throws
		}
	}
	//
	func delete() -> String? // err_str
	{
		assert(self._id != nil)
		NotificationCenter.default.post(
			name: NotificationNames.willBeDeleted.notificationName,
			object: self
		)
		let (err_str, _) = DocumentPersister.shared.RemoveDocuments(
			inCollectionNamed: self.collectionName(),
			withIds: [ self._id! ]
		)
		if err_str != nil {
			DDLog.Error("Persistence", "Error while deleting object: \(err_str!.debugDescription)")
		} else {
			DDLog.Deleting("Persistence", "Deleted \(self).")
		}
		return err_str

	}
}
