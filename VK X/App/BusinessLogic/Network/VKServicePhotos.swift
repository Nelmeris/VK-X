//
//  VKServicePhotos.swift
//  VK X
//
//  Created by Артем Куфаев on 02/05/2019.
//  Copyright © 2019 NONE. All rights reserved.
//

import Alamofire

extension VKService {
    
    func getAllPhotos(ownerId: Int, completionHandler: @escaping(DataResponse<[VKPhotoModel]>) -> Void) {
        VKTokenService.shared.getToken { token in
            let request = GetAllPhotos(baseUrl: self.baseUrl, version: self.apiVersion, token: token, ownerId: ownerId)
            self.request(request: request, completionHandler: completionHandler)
        }
    }
    
}

extension VKService {
    
    struct GetAllPhotos: RequestRouter {
        let baseUrl: URL
        let method: HTTPMethod = .get
        let path: String = "photos.getAll"
        
        let version: Double
        let token: String
        
        let ownerId: Int
        var parameters: Parameters? {
            return [
                "v": version,
                "access_token": token,
                "owner_id": ownerId
            ]
        }
    }
    
}
