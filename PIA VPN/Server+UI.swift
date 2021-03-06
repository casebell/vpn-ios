//
//  Server+UI.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/11/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary
import AlamofireImage

extension Server: CustomStringConvertible {
    func name(forStatus status: VPNStatus) -> String {
        switch status {
//        case .connecting, .changingServer, .connected:
        case .connected:
            guard !isAutomatic else {
                let effectiveServer = Client.providers.vpnProvider.profileServer ?? Client.providers.serverProvider.targetServer
                return "\(name) (\(effectiveServer.name))"
            }
            return name
            
        case .connecting:
            return L10n.Dashboard.Vpn.connecting
        case .disconnecting:
            return L10n.Dashboard.Vpn.disconnecting
        case .disconnected:
            return name
        }
    }
    
    func flagServer(forStatus status: VPNStatus) -> Server {
        switch status {
//        case .connecting, .changingServer, .connected:
        case .connecting, .connected:
            guard !isAutomatic else {
                return Client.providers.vpnProvider.profileServer ?? Client.providers.serverProvider.targetServer
            }
            return self
            
        default:
            return self
        }
    }

    public var description: String {
        return "\(name) [\(country)], \(hostname)"
    }
}

extension UIImageView {
    func setImage(fromServer server: Server) {
        let imageName = "flag-\(server.country.lowercased())"
        guard let image = UIImage(named: imageName) else {
            af_setImage(withURL: server.flagURL, placeholderImage: Asset.Flags.flagUniversal.image)
            return
        }
        self.image = image.withRenderingMode(.alwaysOriginal)
    }
}

extension UIButton {
    func setImage(fromServer server: Server) {
        let imageName = "flag-\(server.country.lowercased())"
        guard let image = UIImage(named: imageName) else {
            af_setImage(for: .normal, url: server.flagURL, placeholderImage: Asset.Flags.flagUniversal.image)
            return
        }
        let original = image.withRenderingMode(.alwaysOriginal)
        self.setImage(original.image(alpha: 0.7), for: .normal)
        self.setImage(image.withRenderingMode(.alwaysOriginal), for: .highlighted)
        
    }
}

extension UIImage {
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
