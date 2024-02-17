//
//  QQResponseSearchResult.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

struct QQResponseSearchResult: Decodable {
    let data: Data
    let code: Int
    
    /*
    let message: String
    let notice: String
    let subcode: Int
    let time: Int // time stamp
    let tips: String
     */
    
    struct Data: Decodable {
        let song: Song
        
        /*
        let keyword: String
         ...
         */
        
        struct Song: Decodable {
            let list: [Item]
            enum CodingKeys: String, CodingKey {
                case list = "itemlist"
            }
            /*
            let curnum: Int
            let curpage: Int
            let totalnum: Int
             */
            
            struct Item: Decodable {
                let songmid: String
                let songname: String
                let singer: String
                /*
                let albumname: String
                let interval: Int
                 */
                enum CodingKeys: String, CodingKey {
                    case songmid = "mid"
                    case songname = "name"
                    case singer
                }
                /*
                let albummid: String
                let albumname_hilight: String
                let alertid: Int
                let belongCD: Int
                let cdIdx: Int
                let chinesesinger: Int
                let docid: String
                let format: String
                let isonly: Int
                let lyric: String
                let lyric_hilight: String
                let media_mid: String
                let msgid: Int
                let newStatus: Int
                let nt: Int
                let pay: Pay
                let preview: Preview
                let pubtime: Int
                let pure: Int
                let size128: Int
                let size320: Int
                let sizeape: Int
                let sizeflac: Int
                let sizeogg: Int
                let songid: Int
                let songname_hilight: String
                let songurl: URL?
                let strMediaMid: String
                let stream: Int
                let `switch`: Int
                let t: Int
                let tag: Int
                let type: Int
                let ver: Int
                let vid: String
                 */
                
                // let grp: [Any]
                /*
                struct Pay: Decodable {
                    let payalbum: Int
                    let payalbumprice: Int
                    let paydownload: Int
                    let payinfo: Int
                    let payplay: Int
                    let paytrackmouth: Int
                    let paytrackprice: Int
                }
                
                struct Preview: Decodable {
                    let trybegin: Int
                    let tryend: Int
                    let trysize: Int
                }
                
                struct Singer: Decodable {
                    let name: String
                    
                    
                    let id: Int
                    let mid: String
                    let name_hilight: String
                }
                */
            }
        }
    }
}

extension QQResponseSearchResult {
    
    var songs: [Data.Song.Item] {
        return data.song.list
    }
}
