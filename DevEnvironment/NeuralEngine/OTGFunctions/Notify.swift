//
//  Notify.swift
//  DevEnvironment
//
//  Created by Shalini Sivakumar on 27/03/25.
//

import SwiftUI

public func Notify(UID: String, msg: String) {

    _ = DF.executeQuery("""
                        CREATE TABLE IF NOT EXISTS send_msg_via_unique_member_id (
                            uid VARCHAR(50) NOT NULL,
                            message TEXT,
                            area VARCHAR(100),
                            mcounti VARCHAR(50),
                            fromdat DATE,
                            ftodat DATE,
                            ftotim TIME,
                            ftovername VARCHAR(100),
                            ftover VARCHAR(100),
                            ftopid VARCHAR(50),
                            todat DATE,
                            totim TIME,
                            tovername VARCHAR(100),
                            tover VARCHAR(100),
                            topid VARCHAR(50),
                            ipmac VARCHAR(50),
                            deviceanduserainfo VARCHAR(255),
                            basesite VARCHAR(100),
                            owncomcode VARCHAR(50),
                            testeridentity VARCHAR(100),
                            testcontrol VARCHAR(100),
                            adderpid VARCHAR(50),
                            addername VARCHAR(100),
                            adder VARCHAR(100),
                            syncstatus VARCHAR(50),
                            doe DATE,
                            toe TIME,
                            PRIMARY KEY (uid)
                        );
                        """)
    
    let insertQuery = """
    INSERT INTO send_msg_via_unique_member_id (
        uid, message, area, mcounti, fromdat, ftodat, ftotim,
        ftovername, ftover, ftopid, todat, totim, tovername, tover, topid,
        ipmac, deviceanduserainfo, basesite, owncomcode, testeridentity,
        testcontrol, adderpid, addername, adder, syncstatus, doe, toe
    ) VALUES (
        '\(UID)', '\(msg)', 'Chennai', 'MC001', '', '', '10:30:00',
        'OverName1', 'Over1', 'PID001', '2025-03-26', '15:45:00', 'OverName2', 'Over2', 'PID002',
        '192.168.1.1', 'MacOS-Safari', 'BaseSite1', 'COM001', 'Tester1',
        'Control1', 'PID003', 'Adder1', 'AdderDetail', 'SYNCED', '\(getDate())', '\(getTime())'
    );
    """
    _ = DF.executeQuery(insertQuery)  // Removed extra parameters
}

