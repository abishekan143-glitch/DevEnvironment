//
//  UserInfo.swift
//  DevEnvironment
//
//  Created by Raghul S on 28/02/25.
//

public class User{
    private var name: String?
    private var id: String?
    private var area: String?
    private var ownComCode: String?
    
    init(){
        name = nil
        id = nil
        area = "skytest"
        ownComCode = "developer"
    }
    
    public func setUserInfo(name: String, id: String, area: String, ownComCode: String){
        self.name = name
        self.id = id
        self.area = area
        self.ownComCode = ownComCode
    }
    
    public func getName() -> String {
        return self.name ?? "Attention Required : getName is called before User Name is set"
    }
    
    public func getId() -> String {
        return self.id ?? "Attention Required : getId is called before User ID is set"
    }
    
    public func getArea() -> String{
        return self.area ?? "Attention Required : getArea is called before User Area is set"
    }
    
    public func getOwnComCode() -> String{
        return self.ownComCode ?? "Attention Required : getOwnComCode is called before User OwnComCode is set"
    }
}

public var user = User()

