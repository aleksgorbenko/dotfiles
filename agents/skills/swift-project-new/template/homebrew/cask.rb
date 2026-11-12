cask "__SLUG__" do
  version "0.0.0"
  sha256 :no_check

  url "https://__FEED_HOST__/apps/__SLUG__/download/v#{version}/__APP__-#{version}.dmg"
  name "__APP__"
  desc "One line on what the app does, without its name"
  homepage "https://__FEED_HOST__/apps/__SLUG__/"

  livecheck do
    url "https://__FEED_HOST__/apps/__SLUG__/appcast.xml"
    strategy :sparkle
  end

  auto_updates true
  depends_on macos: :sequoia

  app "__APP__.app"

  zap trash: [
    "~/Library/Application Support/__BUNDLE_ID__",
    "~/Library/Caches/__BUNDLE_ID__",
    "~/Library/HTTPStorages/__BUNDLE_ID__",
    "~/Library/Preferences/__BUNDLE_ID__.plist",
  ]
end
