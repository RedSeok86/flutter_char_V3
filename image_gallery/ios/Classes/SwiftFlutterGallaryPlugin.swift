import Flutter
import UIKit
import Photos

public class SwiftFlutterGallaryPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "image_gallery", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterGallaryPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "getPlatformVersion") {
            result("iOS " + UIDevice.current.systemVersion)
        }
        else if (call.method == "getAllImages") {
            
            DispatchQueue.main.async {
                
                let imgManager = PHImageManager.default()
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                //requestOptions.resizeMode = .exact
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                
                let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
                var allImages = [String]()
                
                var totalItration = 0
                print("fetchResult.count : \(fetchResult.count)")
                var acount = 0
                var savedLocalIdentifiers = [String]()
                var counter = fetchResult.count < 15 ? fetchResult.count : 15

                for index in 0 ..< counter
                {
                    let asset = fetchResult.object(at: index) as PHAsset
                    let localIdentifier = asset.localIdentifier
                    savedLocalIdentifiers.append(localIdentifier)
                    
                    imgManager.requestImage(for: asset, targetSize: /* PHImageManagerMaximumSize, */CGSize(width: 512.0, height: 512.0), contentMode: .aspectFit, options: requestOptions, resultHandler:{(image, info) in
                        
                        if image != nil {
                            var imageData: Data?
                            /* if let cgImage = image!.cgImage, cgImage.renderingIntent == .defaultIntent {
                                imageData = UIImageJPEGRepresentation(image!, 0.75)
                            }
                            else {
                                imageData = UIImagePNGRepresentation(image!)
                            } */
                            imageData = image!.pngData();
                            let guid = ProcessInfo.processInfo.globallyUniqueString;
                            let tmpFile = String(format: "image_picker_%@.png", guid);
                            let tmpDirectory = NSTemporaryDirectory();
                            let tmpPath = (tmpDirectory as NSString).appendingPathComponent(tmpFile);
                            if(FileManager.default.createFile(atPath: tmpPath, contents: imageData, attributes: [:])) {
                                allImages.append(tmpPath)
                            }
                        }
                        totalItration += 1
                        if totalItration == counter {
                            result(allImages)
                        }
                    })
                }
            }
        }
    }
}
