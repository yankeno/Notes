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
  - 以下では第一引数$1 と"^a"と比較している

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

## シェルの基本

### 標準入出力・標準エラー出力

- ファイル記述子(ファイルディスクリプタ)とは、コマンドの入出力先がどこかを管理するための番号

| 数字 | 意味           |
| ---- | -------------- |
| 0    | 標準入力       |
| 1    | 標準出力       |
| 2    | 標準エラー出力 |

```bash
# lsの中身をaに書き出す
$ ls 1> a

# aの行数をカウント
$ wc -l < a
$ wc -l 0< a
212

# sedのエラー出力をaに書き出す
$ sed 2> a
```

- 出力のパイプ渡し

```bash
$ sed 2>&1 | wc -l

# |&は標準出力も標準エラー出力もまとめて渡すための記号
$ sed |& wc -l
```

### 繰り返し

- `for 文`での繰り返し

```bash
$ set aa bb cc
$ for x in "$1" "$2" "$3"; do echo $x; done
aa
bb
cc
```

- `while 文`での繰り返し
  - `read` が読めなくなるまで`do`に記述した処理が繰り返される

```bash
$ seq 3 | while read x; do echo $x; done
1
2
3
```

### 終了ステータス

- `$?`で直前のコマンドの終了ステータスが確認できる

```bash
# 検索対象がヒット
$ grep 'bash' /etc/passwd
root:x:0:0:root:/root:/bin/bash
okino:x:1000:1000:okino:/home/okino:/bin/bash
$ echo $?
0 # 0(成功)

# 検索対象が存在しない
$ grep 'bush' /etc/passwd
$ echo $?
1 # 1(検索対象なし)が入る

# ファイル名を間違える
$ grep 'bush' /etc/passwddddddddddd
grep: /etc/passwddddddddddd: No such file or directory
$ echo $?
2

# コマンド名を間違える
$ grep 'bush' /etc/passwd
Command 'gre' not found, did you mean:
  command 'grv' from snap grv (0.3.2-5-gcffa246)
  command 'grn' from deb groff (1.22.4-8build1)
  command 'grep' from deb grep (3.7-1build1)
  command 'gie' from deb proj-bin (8.2.1-1)
  command 'tre' from deb tre-command (0.3.6-2)
  command 're' from deb re (0.1-7build1)
  command 'ge' from deb pvm-examples (3.4.6-3.2)
  command 'grc' from deb grc (1.13.1-1)
  command 'gle' from deb gle-graphics (4.2.5-9)
  command 'gri' from deb gri (2.12.27-1build1)
  command 'gpre' from deb firebird3.0-utils (3.0.8.33535.ds4-1ubuntu2)
See 'snap info <snapname>' for additional versions.
$ echo $?
127 # bashが終了ステータスをセット
```

### 変数展開

- `${parameter}`: 参照

```bash
$ hoge="hoge-value"
$ echo ${hoge}
hoge-value
```

- `${parameter:-word}`: デフォルト値(代入なし)

```bash
$ echo ${foo:-"default-value"}
default-value

# 変数の中身は変わっていない
$ echo ${hoge}
hoge-value
```

- `${parameter:=word}`: デフォルト値(代入あり)

```bash
# 未定義のため何も表示されない
$ echo ${foo}

$ echo ${foo:="default-value"}
default-value

# 変数の中身は書き変わっている
$ echo ${foo}
default-value
```

- `${parameter-work}`: 変数未定義時デフォルト値(代入なし)

```bash
$ echo ${hoge-"default-value"}
hoge-value

$ unset hoge
$ echo ${hoge-"hoge-default"}
hoge-default

# 変数は未定義のまま
$ echo ${hoge}
```

- `${parameter=work}`: 変数未定義時デフォルト値(代入あり)

```bash
$ echo ${hoge="hoge-default"}
hoge-value

$ unset hoge
$ echo ${hoge="hoge-default"}
hoge-default

$ echo ${hoge}
hoge-default
```

- その他は[【シェル芸人への道】Bash の変数展開と真摯に向き合う](https://qiita.com/t_nakayama0714/items/80b4c94de43643f4be51)を参照

### 大文字 <-> 小文字の変換

- ${variable^^}: 全て大文字に変換

```bash
$ str='Hello World!'
$ echo ${str^^}
HELLO WORLD!
```

- ${variable,,}: 全て小文字に変換

```bash
$ echo ${str,,}
hello world!
```

- ${variable^}: 先頭 1 文字を大文字に変換

```bash
$ str=hello
$ echo ${str^}
Hello
```

- ${variable,}: 先頭 1 文字を小文字に変換

```bash
$ str=HELLO
$ echo ${str,}
hELLO
```

### その他

- 特別な変数

| 変数名  | 意味                                    |
| ------- | --------------------------------------- |
| IFS     | デリミタ(区切り文字)を定義              |
| RANDOM  | 0 から 32767 までのランダムな整数を生成 |
| SECONDS | スクリプトが開始されてからの秒数を格納  |

- ヒアストリングで変数をコマンドに入力できる

```bash
$ cat <<< $SHELL
/bin/bash
```

- `@`と`*`は微妙に挙動が異なる
  - スクリプト内では`$@`を使用した方がよい

```bash
$ set aa bb cc

# $@は$1以降の引数を持っている
$ for x in "$@"; do echo $x; done
aa
bb
cc

# $*は＄1以降の引数を1つの文字列にまとめて持っている
# -> 引数内の内の特殊文字やワイルドカードがシェルによって解釈され、展開される可能性がある
$ for x in $*; do echo $x; done
aa
bb
cc

# "$*"は$1以降の引数を1つの文字列にまとめて持っている
# -> 引数は1つの文字列として解釈される
$ for x in "$*"; do echo $x; done
aa bb cc

# 実験
$ set "aa" "bb" "cc dd"
$ echo $@
aa bb cc dd

# 区切り文字であるスペースが含まれていても正しく解釈されている
$ for x in "$@"; do echo $x; done
aa
bb
cc dd

# 1つの文字列として解釈している
$ for x in "$*"; do echo $x; done
aa bb cc dd

# クォートが入っていないため、引数内のスペースが区切り文字として解釈されている
$ for x in $*; do echo $x; done
aa
bb
cc
dd
```

- テストコマンド`[`

```bash
$ [ 10 -gt 100 ] # -gtは>(大なり)の意
$ echo $?
1

# testというコマンドでも同じことができる
$ test 10 -gt 100
$ echo $?
1
```

- ファイルが存在するかどうかを判定する

```bash
$ [ -e unfile ] || touch unfile
```

### シバン(shebang)とは

スクリプトの 1 行目に記載してある、`#!`から始まる 1 行目のこと。スクリプトを読み込むインタプリタを指定する。

```bash
#!/bin/bash <- コレ
echo hello
```

## 基本 Tips

- 変数展開はなるべく`${}`を使用する

## 参考サイト

- [Shell 特殊変数](https://qiita.com/a_yasui/items/ec4f75b300410af8958d)
- [ShellCheck](https://www.shellcheck.net/)
