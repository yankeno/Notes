# シェル・ワンライナー 160 本ノック

## `grep`コマンド

- 特定のオプションの説明を出力する

```bash
$ man ls | grep -A 1 '^  *-a'
```

## `awk` コマンド

- 引数を扱う

```bash
$ seq 5 | awk '$1 % 2 == 0 {printf("%s 偶数\n", $1)}'
2 偶数
4 偶数
```

- `sort` と `uniq` による集計

```bash
$ seq 5 | awk '{ print $1 % 2 ? "奇数" : "偶数" }' | sort | uniq -c | awk '{ print $2,$1 }'
偶数 2
奇数 3
```

- 正規表現と比較する演算子`~`

```bash
$ echo 'abcde' | awk '{if($1~"^a") print "hoge"}'
hoge
```

- 組み込み変数 NF(Number of fields)は現在の行のフィールド数が格納される

```bash
$ echo 'a b c d' | awk '{print $(NF-2)}'
2
```

- F オプションで区切り文字を変更する

```bash
$ echo 'a:b:c:d' | awk -F: '{print $3}'
c
```

- `'/開始パターン/,/終了パターン/'`を指定して、開始パターンにマッチした行から終了パターンにマッチした行を表示することができる

## `xargs`コマンド

- 受け取った引数を使用して新たにコマンドを実行する

```bash
# 1,2,3,4という名前のディレクトリを作成
$ seq 4 | xargs mkdir
```

- I オプションで引数を展開する

```bash
# dir_1 ~ dir_4という名前のディレクトリを作成
$ seq 4 | xargs -I@ mkdir dir_@
```

## コマンド置換

- $(コマンド)または`コマンド`でコマンドの実行結果を展開して使用できる

```bash
$ touch "$(date --date "-7 days" +%Y%m%d)_memo"
```

## シバン(shebang)とは

スクリプトの 1 行目に記載してある、`#!`から始まる 1 行目のこと。スクリプトを読み込むインタプリタを指定する。

```bash
#!/bin/bash <- コレ
echo hello
```
