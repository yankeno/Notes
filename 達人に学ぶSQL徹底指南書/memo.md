# 1. CASE 式のススメ

- CASE 式の ELSE は必ず書く  
  ELSE がない場合は CASE に該当しないものは `NULL` になる

- 条件分岐を用いた UPDATE  
  以下のように UPDATE の SET 句の中で CASE 式を書くことも可能

```sql
UPDATE Personnel
SET salary = CASE
    WHEN salary >= 300000
        THEN salary * 0.9
    WHEN salary >= 250000 AND salary < 280000
        THEN salary * 1.2
    ELSE salary
END;
```

- CASE 式はどこにでも書ける
  - SELECT 句
  - WHERE 句
  - GROUPBY 句
  - HAVING 句
  - ORDERBY 句
  - PARTITIONBY 句
  - CHECK 制約の中関数の引数述語の引数
  - 他の式の中（CASE 式自身も含む）

# 3. 自己結合の使い方

<u>_Products_</u>
| name | price |
| :----: | ----- |
| りんご | 100 |
| みかん | 50 |
| バナナ | 80 |

```sql
-- 組み合わせを得るSQL
SELECT
    P1.name AS name_1,
    P2.name AS name_2
FROM Products P1
INNER JOIN Products P2
    ON P1.name > P2.name;
```

-> 「=」以外の比較演算子(>, <, <>)を使って行う結合を`非等値結合`と呼ぶ

<u>_Result_</u>

| name_1 | name_2 |
| ------ | ------ |
| りんご | みかん |
| バナナ | みかん |
| バナナ | りんご |

- 自己結合は非等値結合と組み合わせて使うのが基本

# 4. 3 値論理と NULL

- SQL は 3 値論理を採用している
  - true
  - false
  - unknown

<u>_3 値論理の真理表(NOT)_</u>
|x|NOT x|
|---|---|
|t|f|
|u|u|
|f|t|

<u>_3 値論理の真理表(AND)_</u>
|AND|t|u|f|
|---|---|---|---|
|t|t|u|f|
|u|u|u|f|
|f|f|f|f|

<u>_3 値論理の真理表(OR)_</u>
|OR|t|u|f|
|---|---|---|---|
|t|t|t|f|
|u|t|u|u|
|f|f|u|f|

- nullable なカラムの場合、単純に NOT IN を NOT EXISTS に置き換えることはできない

# 5. EXISTS 述語の使い方

- 述語 = 戻り値が`真理値`になる関数
- EXISTS 以外の述語(ex. =, >, <, LIKE, BETWEEN, IN)は 1 行を入力とする
- EXISTS は行の集合を入力とする
- NOT EXISTS を生かすために二重否定への変換に慣れる
  - 全ての行について〜 = 〜でない行が 1 つも存在しない

# 6. HAVING 句の力

- 現在の標準 SQL では HAVING 句を(ORDER BY を使わず)単体で使用可能  
  -> ただし SELECT で列を参照できなくなるので、固定値を返すか、集約関数を使用する必要がある

- COUNT の性質

  - COUNT(\*) : NULL を`カウントする`
  - COUNT(列名) : NULL を`カウントしない`

- COUNT の性質を使った条件

<u>_Students_</u>
| student_id | dpt | sbmt_date |
| ---------- | -------- | ---------- |
| 100 | 理学部 | 2018-10-15 |
| 101 | 理学部 | 2018-09-28 |
| 102 | 文学部 | |
| 103 | 文学部 | 2018-09-22 |
| 200 | 文学部 | 2018-09-15 |
| 201 | 工学部 | |
| 202 | 経済学部 | 2018-09-25 |

-> レポートを提出してる場合は sbmt_date に日付が入る

```sql
-- 提出日に NULL を含まない(全学生がレポートを提出している)学部を選択
-- sbmt_date に NULL を含んでいる場合、
-- COUNT(*) と COUNT(sbmt_date) が一致しない
SELECT
    dpt
FROM
    Students
GROUP BY
    dpt
HAVING
    COUNT(*) = COUNT(sbmt_date);
```

<u>_Result_</u>
|dpt|
|---|
|理学部|
|経済学部|

- ダブりを検出する方法

```sql
-- 重複を排除して COUNT を取ると行数に差異が出る
SELECT
    center
FROM
    Materials
GROUP BY
    center
HAVING
    COUNT(material) <> COUNT(DISTINCT material);
```

- WHERE 句が集合の要素の性質を調べるのに対し、HAVING 句は集合自身の性質を調べる
- SQL で検索条件を設定する時は、検索対象となる実体が集合の要素なのかを見極めることが基本
  - 実体 1 つにつき 1 行が対応している -> 要素なので WHERE 句を使う
  - 実体 1 つにつき複数行が対応している -> 集合なので HAVING 句を使う

<u>_集合の性質を調べるための条件の使い方一覧_</u>
|条件式|用途|
|---|---|
|COUNT(DISTINCT col) = COUNT(col)|col の値が一意である|
|COUTN(\*) = COUNT(col)|col に NULL が存在しない|
|COUNT(\*) = MAX(col)|col は歯抜けのない連番(開始値は 1)|
|COUNT(\*) = MAX(col) - MIN(col) + 1|col は歯抜けのない連番(開始値は任意の整数)|
|MIN(col) = MAX(col)|col が 1 つだけの値を持つか、または NULL である|
|MIN(col) \* MAX(col) > 0|すべての col_x の符号が同じである|
|MIN(col) \* MAX(col) < 0|最大値の符号が正で最小値の符号が負|
|MIN(ABS(col)) = 0|col は少なくとも 1 つのゼロを含む|
|MIN(col - 定数) = MAX(col - 定数)|col の最大値と最小値が指定した定数から同じ幅の距離にある|

# 8. 外部結合の使い方

- スカラサブクエリはパフォーマンスが悪い

<u>**小ネタ: MySQL WorkBench で SQL を一括実行する方法**</u>

```
※実行する SQL を選択した状態で
Cmd + Shift + Enter
```

- 存在しないデータも表側に表示して集計する

<u>_TblPop_</u>

| pref_name | age_class | sex_cd | population |
| --------- | --------- | ------ | ---------- |
| '千葉'    | '1'       | 'f'    | '1000'     |
| '千葉'    | '1'       | 'm'    | '900'      |
| '千葉'    | '3'       | 'f'    | '900'      |
| '東京'    | '1'       | 'f'    | '1500'     |
| '東京'    | '1'       | 'm'    | '900'      |
| '東京'    | '3'       | 'f'    | '1200'     |
| '秋田'    | '1'       | 'f'    | '800'      |
| '秋田'    | '1'       | 'm'    | '400'      |
| '秋田'    | '3'       | 'f'    | '1000'     |
| '秋田'    | '3'       | 'm'    | '1000'     |
| '青森'    | '1'       | 'f'    | '500'      |
| '青森'    | '1'       | 'm'    | '700'      |
| '青森'    | '3'       | 'f'    | '800'      |

上記のテーブルから以下の結果を得るには

|     |     | 東北   | 関東   |
| --- | --- | ------ | ------ |
| '1' | 'm' | '1100' | '1800' |
| '1' | 'f' | '1300' | '2500' |
| '2' | 'm' |        |        |
| '2' | 'f' |        |        |
| '3' | 'm' | '1000' |        |
| '3' | 'f' | '1800' | '2100' |

```sql
SELECT MASTER.age_class AS age_class,
       MASTER.sex_cd AS sex_cd,
       DATA.pop_tohoku AS pop_tohoku,
       DATA.pop_kanto AS pop_kanto
  FROM (SELECT age_class, sex_cd
          FROM TblAge CROSS JOIN TblSex ) MASTER --クロス結合でマスタ同士の直積を作る
            LEFT OUTER JOIN
             (SELECT age_class, sex_cd,
                     SUM(CASE WHEN pref_name IN ('青森', '秋田')
                              THEN population ELSE NULL END) AS pop_tohoku,
                     SUM(CASE WHEN pref_name IN ('東京', '千葉')
                              THEN population ELSE NULL END) AS pop_kanto
                FROM TblPop
               GROUP BY age_class, sex_cd) DATA
    ON MASTER.age_class = DATA.age_class
   AND MASTER.sex_cd = DATA.sex_cd;
```

- 複数のテーブルから情報を欠落させずに取得する場合は FULL OUTER JOIN を使用する
  ※MySQL8 では使用不可

# 11. SQL を速くするぞ

- NOT IN と NOT EXISTS

<u>_Class_A_</u>
|id|name|
|---|---|
|1|田中|
|2|鈴木|
|3|伊集院|

<u>_Class_B_</u>
|id|name|
|---|---|
|1|田中|
|2|鈴木|
|4|西園寺|

**NOT IN を使用する場合**

```sql
SELECT
    *
FROM
    Class_A
WHERE
    id IN (
        SELECT
            id
        FROM
            Class_B
    );
```

**NOT EXISTS を使用する場合**

```sql
SELECT
    *
FROM
    Class_A A
WHERE
    EXISTS(
        SELECT
            *
        FROM
            Class_B B
        WHERE
            A.id = B.id
    );
```

上記のような場合に EXISTS の方が速いと期待できる理由

1. 結合キーにインデックスが張られていれば Class_B の実表を見ず  
   インデックスの参照のみで済む
2. EXISTS は 1 行でも条件に合致する行を見つけたら検索を打ち切るため、  
   IN のように全表検索の必要がない

- ソートを回避する  
  ソートが行われるとパフォーマンスが低下する。  
  メモリでは足りずストレージを使用した場合は特に顕著なパフォーマンス低下をもたらす。
  ソートが発生する代表的な演算は以下の通り。

  - GROUP BY 句
  - ORDER BY 句
  - 集約関数
  - DISTINCT
  - 集合演算子(UNION, INTERSEPT, EXCEPT)
  - ウィンドウ関数

- WHERE 句で書ける条件は HAVING 句には書かない

  - GROUP BY 句による集約はソートやハッシュの演算を行うため、  
    事前に行数を絞り込んだ方がソートの負荷が軽減される
  - WHERE 句内でインデックスが利用できる可能性がある

- インデックスを正しく使用する

  - インデックスを利用するときは、`列は裸`

  **col_1 にインデックスが張られている場合**

  ```sql
  -- インデックスが使用されない
  WHERE col_1 * 1.1 > 100

  -- インデックスが使用される
  WHERE col_1 > 100 / 1.1
  ```

  - インデックス列に NULL が存在する場合、インデックスが使用されないことがある
  - 以下のような否定系はインデックスを使用できない
    - <>
    - !=
    - NOT IN
  - OR を使用して条件を結合するとインデックスを使用できなくなるか、  
    使用できたとしても AND に比べて非効率になる
  - `後方一致`、`中間一致`の LIKE 述語で検索するとインデックスが使用されない

  ```sql
  col_1 LIKE '%a'  -- インデックス使用不可
  col_1 LIKE '%a%' -- インデックス使用不可
  col_1 LIKE 'a%'  -- インデックス使用可
  ```

  - 暗黙の型変換が行われた場合、インデックスを使用できない
    - CAST(10, AS CHAR(2)) などと明示的に型を変換すればインデックスを使用可能

- 中間テーブルを減らす

# 22. NULL 撲滅委員会

- コードの場合 -> 未コード化用コードを割り振る  
  1：男性、2：女性、0：未知、9：適用不能 など
- 名前の場合 -> 「名無しの権兵衛」を割り振る  
  不明、UNKNOWN など
- 数値の場合 -> 0 で代替する  
  NULL を 0 に変換して DB に登録する  
  -> ただし、所有しているが中身が 0 であるのと所有していないというのは異なる  
  -> 現実的な案としては...
  1. 0 に変換する
  2. どうしても 0 と NULL を区別したい時だけ NULL を許可する
- 日付の場合 -> 最大値・最小値で代替する  
  '0001-01-01'、'9999-12-31'など

# 用語

- スカラサブクエリ：単一行を返すサブクエリ

```sql
SELECT
    name,
    (
        SELECT
            MAX(amount_paid)
        FROM
            transaction
    ) as max_payment -- サブクエリが複数行を返す場合エラーになるので注意
FROM
    transaction;
```

```sql
SELECT
    name,
    payoff
FROM
    transaction
WHERE
    payoff = (
        SELECT
            MIN(payoff)
        FROM
            transaction
    );
```

- 相関サブクエリ：WHERE 句に外部クエリからの値を使用するサブクエリ

```sql
SELECT
    *
FROM
    earnings e
WHERE
    (
        SELECT
            unit_price
        FROM
            price p
        WHERE
            e.product_name = p.product_name
    ) >= 10000;
```

処理の流れとしては以下の通りとなる

1. 主問合せを実行してレコードを 1 件取り出す
2. 副問合せを実行する
3. WHERE で抽出対象とするかを判定する
4. 1 ~ 3 を繰り返す  
   -> 主問合せに相関して副問合せが実行されるため相関サブクエリと呼ばれる  
   -> 一般的には DB への負荷が大幅に増える  
   -> 対して非相関サブクエリは、副問合せを実行し切ってから主問合せを実行する

# 参考

- [【SQL】相関サブクエリ入門](https://qiita.com/aki3061/items/736abd6ea883ba647586)
- [相関サブクエリとパフォーマンス](https://zenn.dev/kou_row_line/articles/6acb7d888c9f32749c41)
