# JINSMEMESampler
[WIP] Samples using JINS MEME(wearable eye-ware that watches inside of you) on iOS mainly written in Swift.

## Rules
 - RxSwiftで書かれています
 - サンプルのソースはサンプル名と同じ名前のフォルダに配置していく形をとっています

## Samples
以下、各サンプルの簡単な説明です。

### DataView
リアルタイムモードデータをtableViewで閲覧できるだけのサンプル。

### Spreadsheet
リアルタイムモードで取得したデータをxx秒おきにPOSTします。
本サンプルでは、POST先はスプレッドシートです。

### Processing 
リアルタイムモードで取得したデータをtcpソケット通信で任意のホストIP/Portに出力します。
本サンプルではProcessingに出力し、Processing側でデータをグラフ化しています。

### Socketio
socket.ioを用いてwebsocketでmacアプリにデータを送信します。
