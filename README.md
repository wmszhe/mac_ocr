# mac_ocr

调用系统OCR和二维码解析

**感谢raycast团队的review！**

**thanks for raycast team to review code**

**https://github.com/raycast/script-commands/pull/735**

**只支持10.15以上系统**

可直接使用编译好的二进制文件 `mac_ocr`

1. 使用 `screencapture` 命令截图
2. 使用 `CIDetector` 识别并解析二维码
3. 如果图片中不包含二维码，使用 `VNRecognizeTextRequest` 识别文本
