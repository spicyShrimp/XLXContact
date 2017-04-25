//
//  XLXContact.swift
//  XLXContact
//
//  Created by charles on 2017/4/25.
//  Copyright © 2017年 charles. All rights reserved.
//

import AddressBook
import Contacts

class XLXContact: NSObject {
    
    private lazy var myAddressBook: ABAddressBook = {
        var error:Unmanaged<CFError>?
        let ab: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        return ab;
    }()
    
    @available(iOS 9.0, *)
    lazy var myContactStore: CNContactStore = {
        let cn:CNContactStore = CNContactStore()
        return cn
    }()
    
    func getContacts() {
        if #available(iOS 9.0, *) {
            checkContactStoreAuth()
        }else {
            checkAddressBookAuth()
        }
    }
    
    func checkAddressBookAuth() {
        switch ABAddressBookGetAuthorizationStatus() {
        case .notDetermined:
            print("未授权")
            requestAddressBookAuthorization(myAddressBook)
        case .authorized:
            print("已授权")
            readContactsFromAddressBook(myAddressBook)
        case .denied, .restricted:
            print("无权限")
            //可以选择弹窗到系统设置中去开启
        }
    }
    
    @available(iOS 9.0, *)
    func checkContactStoreAuth(){
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .notDetermined:
            print("未授权")
            requestContactStoreAuthorization(myContactStore)
        case .authorized:
            print("已授权")
            readContactsFromContactStore(myContactStore)
        case .denied, .restricted:
            print("无权限")
            //可以选择弹窗到系统设置中去开启
        }
    }
    
    func requestAddressBookAuthorization(_ addressBook:ABAddressBook) {
        ABAddressBookRequestAccessWithCompletion(addressBook, {[weak self] (granted, error) in
            if granted {
                print("已授权")
                self?.readContactsFromAddressBook(addressBook)
            }
        })
    }
    
    @available(iOS 9.0, *)
    func requestContactStoreAuthorization(_ contactStore:CNContactStore) {
        contactStore.requestAccess(for: .contacts, completionHandler: {[weak self] (granted, error) in
            if granted {
                print("已授权")
                self?.readContactsFromContactStore(contactStore)
            }
        })
    }
    
    func readContactsFromAddressBook(_ addressBook:ABAddressBook) {
        guard ABAddressBookGetAuthorizationStatus() == .authorized else {
            return
        }
        
        let allContacts = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as Array
        for record in allContacts {
            let currentContact: ABRecord = record
            let name = ABRecordCopyCompositeName(currentContact).takeRetainedValue() as String
            print(name)
            
            let currentContactPhones: ABMultiValue = ABRecordCopyValue(currentContact, kABPersonPhoneProperty).takeRetainedValue() as ABMultiValue
            for i in 0..<ABMultiValueGetCount(currentContactPhones){
                let phoneNumber = ABMultiValueCopyValueAtIndex(currentContactPhones, i).takeRetainedValue() as! String
                print(phoneNumber)
            }
        }
    }
    
    @available(iOS 9.0, *)
    func readContactsFromContactStore(_ contactStore:CNContactStore) {
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            return
        }
        
        let keys = [CNContactFamilyNameKey,CNContactGivenNameKey,CNContactPhoneNumbersKey]
        
        let fetch = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: fetch, usingBlock: { (contact, stop) in
                //姓名
                let name = "\(contact.familyName)\(contact.givenName)"
                print(name)
                //电话
                for labeledValue in contact.phoneNumbers {
                    let phoneNumber = (labeledValue.value as CNPhoneNumber).stringValue
                    print(phoneNumber)
                }
            })
        } catch let error as NSError {
            print(error)
        }
    }
}
