# 2 章 エンドポイントの設計とリクエストの形式

## GET メソッド

- GET メソッドでデータの更新をできるようにしてはいけない
- Google のクローラも GET でリクエストを飛ばしてくる

## POST メソッド

- 新しいリソースの登録に使用する
- 更新、削除には使用しない

## PUT メソッド

- 既存のリソースの更新に使用する
- リクエストには更新したいリソースの URI を指定する

<u>_POST と PUT の違い_</u>

```text
[POST] https://api.example.com/v1/friends
-> 配下に新しいデータを登録する

[PUT]  https://api.example.com/v1/friends/12345
-> 指定したデータそのものを更新する
```

### PATCH メソッド

- リソースの一部を更新する
