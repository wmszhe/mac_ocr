# mac_ocr

调用系统OCR和二维码解析

**只支持10.15以上系统**

1. 使用 `screencapture` 命令截图
2. 使用 `CIDetector` 识别并解析二维码
3. 如果图片中不包含二维码，使用 `VNRecognizeTextRequest` 识别文本