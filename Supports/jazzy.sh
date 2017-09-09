# Clean
rm -rf _sourcekitten.output.json build/ docs/ _temp/

# Source Kitten
swift build
sourcekitten doc --spm-module MediaBrowser > _sourcekitten.output.json

# Jazzy
jazzy --clean \
      --sourcekitten-sourcefile _sourcekitten.output.json \
      --output docs/latest \
      --min-acl public \
      --author "Seungyoun Yi" \
      --author_url "https://twitter.com/younatics" \
      --github_url "https://github.com/younatics/MediaBrowser" \
      --module MediaBrowser

# Publish
git clone git@github.com:younatics/MediaBrowser.git -b gh-pages _temp
cd _temp
git branch -m gh-pages _gh-pages
git checkout --orphan gh-pages
git reset -- *
rm -rf ./*
cp -r ../docs/latest/* ./
git add ./*
git commit -am "Update Documentation"
git push origin gh-pages -f
cd ..

# Clean
rm -rf _sourcekitten.output.json build/ docs/ _temp/
