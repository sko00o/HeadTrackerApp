#!/bin/bash

# iOS App Icon Generator Script
# 将SVG文件转换为iOS应用所需的各种尺寸的PNG图标

# 检查是否提供了SVG文件参数
if [ $# -eq 0 ]; then
    echo "使用方法: $0 <svg文件名>"
    echo "例如: $0 airpods_max_icon_design.svg"
    exit 1
fi

SVG_FILE="$1"
OUTPUT_DIR="HeadTrackerApp/Assets.xcassets/AppIcon.appiconset"

# 检查SVG文件是否存在
if [ ! -f "$SVG_FILE" ]; then
    echo "错误: SVG文件 '$SVG_FILE' 不存在"
    exit 1
fi

# 检查输出目录是否存在
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "错误: 输出目录 '$OUTPUT_DIR' 不存在"
    exit 1
fi

# 检查ImageMagick是否安装
if ! command -v magick &>/dev/null; then
    echo "错误: ImageMagick 未安装。请先安装 ImageMagick"
    echo "可以使用: brew install imagemagick"
    exit 1
fi

echo "开始生成iOS应用图标..."
echo "源文件: $SVG_FILE"
echo "输出目录: $OUTPUT_DIR"
echo ""

# 生成各种尺寸的图标
echo "生成 1024x1024 (App Store)..."
magick "$SVG_FILE" -resize 1024x1024 -background transparent "$OUTPUT_DIR/icon_1024x1024.png"

echo "生成 180x180 (iPhone @3x)..."
magick "$SVG_FILE" -resize 180x180 -background transparent "$OUTPUT_DIR/icon_180x180.png"

echo "生成 120x120 (iPhone @2x)..."
magick "$SVG_FILE" -resize 120x120 -background transparent "$OUTPUT_DIR/icon_120x120.png"

echo "生成 80x80 (iPad @2x)..."
magick "$SVG_FILE" -resize 80x80 -background transparent "$OUTPUT_DIR/icon_80x80.png"

echo "生成 60x60 (iPhone @1x)..."
magick "$SVG_FILE" -resize 60x60 -background transparent "$OUTPUT_DIR/icon_60x60.png"

echo "生成 40x40 (iPad @1x)..."
magick "$SVG_FILE" -resize 40x40 -background transparent "$OUTPUT_DIR/icon_40x40.png"

echo "生成 20x20 (通知/设置)..."
magick "$SVG_FILE" -resize 20x20 -background transparent "$OUTPUT_DIR/icon_20x20.png"

echo ""
echo "✅ 所有图标生成完成！"
echo ""
echo "生成的文件列表:"
ls -la "$OUTPUT_DIR"/*.png

echo ""
echo "📱 iOS图标尺寸说明:"
echo "  • 1024x1024 - App Store 图标"
echo "  • 180x180   - iPhone @3x (60pt × 3)"
echo "  • 120x120   - iPhone @2x (60pt × 2)"
echo "  • 80x80     - iPad @2x (40pt × 2)"
echo "  • 60x60     - iPhone @1x (60pt × 1)"
echo "  • 40x40     - iPad @1x (40pt × 1)"
echo "  • 20x20     - 通知和设置图标"
echo ""
echo "🎨 如果需要修改图标，编辑SVG文件后重新运行此脚本即可"
