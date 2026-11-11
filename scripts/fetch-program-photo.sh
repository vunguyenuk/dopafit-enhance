#!/bin/zsh
# Ảnh bìa chương trình "Chân": André Henrique / Pexels 11191169 (Pexels License, dùng miễn phí). Giữ nguyên màu gốc.
set -eu
cd "${0:A:h:h}"
mkdir -p third_party/challenge-photos/sources
curl -fsSL -o third_party/challenge-photos/sources/pexels-11191169.jpg "https://images.pexels.com/photos/11191169/pexels-photo-11191169.jpeg?auto=compress&cs=tinysrgb&w=1600"
echo "Xong: đã tải ảnh Chân"
