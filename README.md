# Worldonリモートemoji
別インスタンスのカスタムemojiを表示するmikutterプラグインです。

## インストール方法
事前に[Worldon](https://github.com/cobodo/mikutter-worldon)をインストールしてから、以下のコマンドを実行します。

```shell-session
git clone git://github.com/cobodo/worldon_remote_emoji ~/.mikutter/plugin/worldon_remote_emoji
```

## 使い方
例えば`social.mikutter.hachune.net`インスタンスの`:mikuslime:`を使う場合は、
```
:mikuslime@social.mikutter.hachune.net:
```
とトゥートしてください。
twitter等から流れてきたメッセージにも無差別に反応します。

カスタムemojiの一覧は30分キャッシュしますが、追加されたemojiがキャッシュに見つからなかった場合は再取得します。

