//
//  XiamiResponseSearchResult.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation

struct XiamiResponseSearchResult : Decodable {
    let data : Data
    
    /*
    let state : Int?
    let message : String?
    let request_id : String?
     */
    
    struct Data : Decodable {
        let songs : [Song]
        
        /*
        let total : Int?
        let previous : Int?
        let next : Int?
         */
        
        struct Song : Decodable {
            let song_name : String
            let artist_name : String
            let album_logo : URL?
            let lyric : String?
            
            /*
            let song_id : Int?
            let album_id : Int?
            let album_name : String?
            let artist_id : Int?
            let artist_logo : URL?
            let listen_file : URL?
            let demo : Int?
            let need_pay_flag : Int?
            let purview_roles : [PurviewRoles]?
            let is_play : Int?
            let play_counts : Int?
            let singer : String?
 
            struct PurviewRoles : Codable {
                let quality : String?
                let operation_list : [Operation_list]?
                
                struct Operation_list : Codable {
                    let purpose : Int?
                    let upgrade_role : Int?
                }
            }
             */
        }
    }
}
