import Foundation
import CoreImage
import Cocoa
import Vision

// 调用系统OCR和二维码解析

let tmpPath = "/tmp/ocr.png"
var recognitionLanguages = ["zh-CN", "en-US"]
var joiner = " "


func doShell(_ command: String) -> String {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

    return output
}

func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
    let context = CIContext(options: nil)
    if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
        return cgImage
    }
    return nil
}

func paste(text: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.clearContents()
    pasteboard.setString(text, forType: .string)
}

func recognizeTextHandler(request: VNRequest, error: Error?) {
    guard let observations =
    request.results as? [VNRecognizedTextObservation] else {
        return
    }
    let recognizedStrings = observations.compactMap { observation in
        // Return the string of the top VNRecognizedText instance.
        observation.topCandidates(1).first?.string
    }

    // Process the recognized strings.
    let joined = recognizedStrings.joined(separator: joiner)

    print("识别结果: " + joined)

    paste(text: joined)
}

func detectText(fileName: URL) -> [String]? {
    if let ciImage = CIImage(contentsOf: fileName) {
        guard let img = convertCIImageToCGImage(inputImage: ciImage) else {
            return nil
        }

        let requestHandler = VNImageRequestHandler(cgImage: img)

        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        request.recognitionLanguages = recognitionLanguages

        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    return nil
}

func recognitionQRCode(fileName: URL) -> Bool {
    //1. 创建过滤器
    let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: nil)

    //2. 获取CIImage
    guard let ciImage = CIImage(contentsOf: fileName) else {
        return false
    }

    //3. 识别二维码
    guard let features = detector?.features(in: ciImage) else {
        return false
    }

    //4. 遍历数组, 获取信息
    var isQRCode = false
    var result = ""
    for feature in features as! [CIQRCodeFeature] {
        if feature.type == "QRCode" {
            isQRCode = true
        }
        result += feature.messageString ?? ""
        result += "\n"
    }
    print("二维码为: \n" + result)
    paste(text: result)

    return isQRCode
}

func main() {
    // 只支持10.15以上系统
    guard #available(OSX 10.15, *) else {
        print("只支持10.15以上系统")
        return
    }
    // 截图
    let _ = doShell("/usr/sbin/screencapture -i " + tmpPath)
    // 判断是否是二维码，如果是二维码，解析二维码
    guard recognitionQRCode(fileName: URL(fileURLWithPath: tmpPath)) else {
        // 如果不是二维码，OCR文本
        let _ = detectText(fileName: URL(fileURLWithPath: tmpPath))
        return
    }
}

main()


