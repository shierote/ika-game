# イカゲーム
https://github.com/shierote/ika-game

# 環境構築
MacOSの環境を前提としています(Windows、Linuxで動くかはわかりません)。
Ruby、Bundler(Rubyのパッケージ管理ツール)をinstall(バージョンは以下)
```
$ ruby -v
ruby 2.6.0p0 (2018-12-25 revision 66547) [x86_64-darwin18]

$ bundle -v
Bundler version 1.17.3
```

```
$ git clone git@github.com:shierote/ika-game.git
$ cd ika-game
```

必要なライブラリをinstall
```
$ bundle install --path vendor/bundler
```

Railsサーバー、Redisのサーバーを立ち上げる
```
$ redis-server

(別ウィンドウで)
$ bundle exec rails server
```

ブラウザでlocalhost:3000にアクセス
```
open http://localhost:3000/
```

いくつかのブラウザでlocalhost:3000にアクセスすればゲームが始まる。ゲームが始まらない場合は何度かリロードしてみてください。

