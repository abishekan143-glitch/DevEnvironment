//
//  Sender.swift
//  DevEnvironment
//
//  Created by Shalini Sivakumar on 28/03/25.
//

import SwiftUI

public func sendSMS(phonenumber: String, message: String){
    _ = DF.executeQuery("""
                       CREATE TABLE IF NOT EXISTS send_msg_via_sms (
                       phonenumber TEXT,
                       message TEXT,
                       area TEXT,
                       mcounti TEXT,
                       fromdat DATE,
                       ftodat DATE,
                       ftotim TIME,
                       ftovername TEXT,
                       ftover TEXT,
                       ftopid TEXT,
                       todat DATE,
                       totim TIME,
                       tovername TEXT,
                       tover TEXT,
                       topid TEXT,
                       ipmac TEXT,
                       deviceanduserainfo TEXT,
                       basesite TEXT,
                       owncomcode TEXT,
                       testeridentity TEXT,
                       testcontrol TEXT,
                       adderpid TEXT,
                       addername TEXT,
                       adder TEXT,
                       syncstatus TEXT,
                       doe DATE,
                       toe TIME
                    );
                    """)

    _ = DF.executeQuery("""
               INSERT INTO send_msg_via_sms (
                   phonenumber, message, area, mcounti, fromdat, ftodat, ftotim,
                   ftovername, ftover, ftopid, todat, totim, tovername, tover, topid,
                   ipmac, deviceanduserainfo, basesite, owncomcode, testeridentity,
                   testcontrol, adderpid, addername, adder, syncstatus, doe, toe
               ) VALUES (
                   '\(phonenumber)', '\(message)', 'Chennai', 'MC001', '', '', '',
                   '', '', '', '', '15:45:00', 'OverName2', 'Over2', 'PID002',
                   '192.168.1.1', 'MacOS-Safari', 'BaseSite1', 'COM001', 'Tester1',
                   'Control1', 'PID003', 'Adder1', 'AdderDetail', 'SYNCED', '\(getDate())', '\(getTime())'
               );
    """)
}



public func sendEmail1(email: String, subject: String, body: String){
    _ = DF.executeQuery("""
                        CREATE TABLE if not exists send_msg_via_email (
                        email TEXT,
                        subject TEXT,
                        body TEXT,
                        area TEXT,
                        mcounti TEXT,
                        fromdat DATE,
                        ftodat DATE,
                        ftotim TIME,
                        ftovername TEXT,
                        ftover TEXT,
                        ftopid TEXT,
                        todat DATE,
                        totim TIME,
                        tovername TEXT,
                        tover TEXT,
                        topid TEXT,
                        ipmac TEXT,
                        deviceanduserainfo TEXT,
                        basesite TEXT,
                        owncomcode TEXT,
                        testeridentity TEXT,
                        testcontrol TEXT,
                        adderpid TEXT,
                        addername TEXT,
                        adder TEXT,
                        syncstatus TEXT,
                        doe DATE,
                        toe TIME
                        );
                        """)
    _ = DF.executeQuery("""
                INSERT INTO send_msg_via_email (
                    email, subject, body, area, mcounti, fromdat, ftodat, ftotim,
                    ftovername, ftover, ftopid, todat, totim, tovername, tover, topid,
                    ipmac, deviceanduserainfo, basesite, owncomcode, testeridentity,
                    testcontrol, adderpid, addername, adder, syncstatus, doe, toe
                ) VALUES (
                    '\(email)', '\(subject)', '\(body)', 'Chennai', 'MC001', '', '', '10:30:00',
                    'OverName1', 'Over1', 'PID001', '2025-03-26', '15:45:00', 'OverName2', 'Over2', 'PID002',
                    '192.168.1.1', 'MacOS-Safari', 'BaseSite1', 'COM001', 'Tester1',
                    'Control1', 'PID003', 'Adder1', 'AdderDetail', 'SYNCED', '\(getDate())', '\(getTime())'
                );
    """)
}

public func sendWhatsapp(groupName: String, msg: String){
    _ = DF.executeQuery("""
                        CREATE TABLE send_msg_via_whatsapp (
                        whatsappnumber TEXT,
                        message TEXT,
                        area TEXT,
                        mcounti TEXT,
                        fromdat DATE,
                        ftodat DATE,
                        ftotim TIME,
                        ftovername TEXT,
                        ftover TEXT,
                        ftopid TEXT,
                        todat DATE,
                        totim TIME,
                        tovername TEXT,
                        tover TEXT,
                        topid TEXT,
                        ipmac TEXT,
                        deviceanduserainfo TEXT,
                        basesite TEXT,
                        owncomcode TEXT,
                        testeridentity TEXT,
                        testcontrol TEXT,
                        adderpid TEXT,
                        addername TEXT,
                        adder TEXT,
                        syncstatus TEXT,
                        doe DATE,
                        toe TIME
                    );

                    """)
    _ = DF.executeQuery("""
               INSERT INTO send_msg_via_whatsapp (
                   whatsappnumber, message, area, mcounti, fromdat, ftodat, ftotim,
                   ftovername, ftover, ftopid, todat, totim, tovername, tover, topid,
                   ipmac, deviceanduserainfo, basesite, owncomcode, testeridentity,
                   testcontrol, adderpid, addername, adder, syncstatus, doe, toe
               ) VALUES (
                   '\(groupName)', '\(msg)', 'Chennai', 'MC001', '', '', '',
                   '', '', '', '', '15:45:00', 'OverName2', 'Over2', 'PID002',
                   '192.168.1.1', 'MacOS-Safari', 'BaseSite1', 'COM001', 'Tester1',
                   'Control1', 'PID003', 'Adder1', 'AdderDetail', 'SYNCED', '\(getDate())', '\(getTime())'
               );
    """)
}
