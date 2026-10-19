#!/usr/bin/env bash
# Create a new SomexAI iPhone app from this template.
#
#   scripts/new-app.sh <slug> "<Display Name>" [ModuleName]
#
#   slug         lowercase, hyphens allowed: becomes the folder somexai-<slug> and bundle ID com.example.<slug>
#   Display Name what appears under the icon and in the store (30 characters max, keyword first)
#   ModuleName   optional Swift module / target name; defaults to the display name without spaces
#
# Example:
#   scripts/new-app.sh oit-diary "OIT Dose Diary"
#   -> ../somexai-oit-diary with target OITDoseDiary and bundle ID com.example.oit-diary
set -euo pipefail

if [ $# -lt 2 ]; then
  sed -n '2,13p' "$0"; exit 1
fi

slug="$1"
display="$2"
module="${3:-$(echo "$display" | tr -cd '[:alnum:]')}"
productslug="${slug//-/}"   # Apple product IDs cannot contain hyphens
if ! [[ "$slug" =~ ^[a-z0-9-]+$ ]]; then echo "slug must be lowercase letters, digits, hyphens"; exit 1; fi
# A colon breaks the YAML in project.yml and an ampersand is eaten by the sed replacements
# below, both of which leave a half-created folder behind. Refuse them up front.
case "$display" in
  *:*) echo "display name cannot contain a colon (it breaks project.yml); set the App Store name in asc/app.json instead"; exit 1;;
  *"&"*) echo "display name cannot contain an ampersand (sed eats it); use 'and'"; exit 1;;
esac
if [ ${#display} -gt 30 ]; then echo "warning: display name is ${#display} characters; App Store limit is 30"; fi

template_dir="$(cd "$(dirname "$0")/.." && pwd)"
dest="$(dirname "$template_dir")/somexai-$slug"
if [ -e "$dest" ]; then echo "$dest already exists"; exit 1; fi

echo "Creating $dest (target $module, bundle com.example.$slug)"
rsync -a --exclude .git --exclude '*.xcodeproj' --exclude DerivedData --exclude .DS_Store "$template_dir/" "$dest/"
cd "$dest"

# Rename directories and files that carry the template name (deepest first).
find . -depth -name '*SomexApp*' -not -path './.git/*' | while read -r path; do
  base="$(basename "$path")"
  mv "$path" "$(dirname "$path")/${base//SomexApp/$module}"
done

# Replace identifiers and display names inside text files.
LC_ALL=C find . -type f \( -name '*.swift' -o -name '*.yml' -o -name '*.md' -o -name '*.plist' \
  -o -name '*.entitlements' -o -name '*.storekit' -o -name '*.json' -o -name '*.sh' \) -print0 \
  | xargs -0 sed -i '' \
    -e "s/com\.somexai\.template\.pro\./com.example.$productslug.pro./g" \
    -e "s/com\.somexai\.template/com.example.$slug/g" \
    -e "s/SomexApp/$module/g" \
    -e "s/Somex App/$display/g" \
    -e "s/somex-app/$slug/g" \
    -e "s#somexai.com/privacy/template/#somexai.com/privacy/$slug/#g"

xcodegen generate
echo
echo "Done. Next:"
echo "  1. open $dest/$module.xcodeproj"
echo "  2. edit Shared/AppConfig.swift (copy, links, entry noun) and $module/StoreKit/Products.storekit (prices)"
echo "  3. drop a 1024x1024 icon into $module/Assets.xcassets/AppIcon.appiconset"
echo "  4. publish the privacy page: cd ../somexai_corp && python3 scripts/privacy.py add $slug \"$display\" && firebase deploy --only hosting"
echo "  5. follow docs/app-store-checklist.md"
