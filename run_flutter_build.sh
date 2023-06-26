# 生成资源映射
fvm flutter packages pub run build_runner build
# 本地创建自动locale_keys.g.dart文件的命令:
fvm flutter pub run easy_localization:generate --source-dir ./assets/translations/en --output-dir lib/gen -f keys -o locale_keys.gen.dart