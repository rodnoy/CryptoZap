#!/bin/bash

echo "🧹 Killing Finder and FinderSyncExtensionHelper..."
killall Finder 2>/dev/null
killall -9 FinderSyncExtensionHelper 2>/dev/null

echo "🔍 Удаление кешей Finder..."
rm -rf ~/Library/Caches/com.apple.finder
rm -f ~/Library/Preferences/com.apple.finder.plist

echo "🧼 Обновление Launch Services (lsregister)..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
-kill -r -domain local -domain system -domain user

echo "🧯 Удаление всех копий расширения FinderSync:"
mdfind "kMDItemCFBundleIdentifier == 'com.orange.labs.immersive.CryptoZap.CryptoZapFinderSync'" | while read -r path; do
  echo "❌ Удаление: $path"
  rm -rf "$path"
done

echo "🔁 Перезапуск Finder..."
open /System/Library/CoreServices/Finder.app

echo "✅ Finder сброшен. Пересобери расширение в Xcode вручную, если нужно."
