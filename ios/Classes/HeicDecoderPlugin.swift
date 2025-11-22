import Flutter
import UIKit
import ImageIO

@available(iOS 11.0, *)
public class HeicDecoderPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_ml_helper/heic_decoder",
            binaryMessenger: registrar.messenger()
        )
        let instance = HeicDecoderPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "decodeHeic":
            guard let args = call.arguments as? [String: Any],
                  let bytes = args["bytes"] as? FlutterStandardTypedData else {
                result(FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "Bytes cannot be null",
                    details: nil
                ))
                return
            }
            decodeHeic(bytes: bytes.data, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    @available(iOS 11.0, *)
    private func decodeHeic(bytes: Data, result: @escaping FlutterResult) {
        guard let imageSource = CGImageSourceCreateWithData(bytes as CFData, nil) else {
            result(FlutterError(
                code: "DECODE_ERROR",
                message: "Failed to create image source from HEIC data",
                details: nil
            ))
            return
        }

        guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            result(FlutterError(
                code: "DECODE_ERROR",
                message: "Failed to create CGImage from HEIC source",
                details: nil
            ))
            return
        }

        // Convert CGImage to PNG data (for compatibility with image package)
        let uiImage = UIImage(cgImage: image)
        guard let pngData = uiImage.pngData() else {
            result(FlutterError(
                code: "CONVERSION_ERROR",
                message: "Failed to convert decoded image to PNG",
                details: nil
            ))
            return
        }

        result(FlutterStandardTypedData(bytes: pngData))
    }
}




