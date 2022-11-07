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
|COUTN(_) = COUNT(col)|col に NULL が存在しない|
|COUNT(_) = MAX(col)|col は歯抜けのない連番(開始値は 1)|
|COUNT(_) = MAX(col) - MIN(col) + 1|col は歯抜けのない連番(開始値は任意の整数)|
|MIN(col) = MAX(col)|col が 1 つだけの値を持つか、または NULL である|
|MIN(col) _ MAX(col) > 0|すべての col_x の符号が同じである|
|MIN(col) \* MAX(col) < 0|最大値の符号が正で最小値の符号が負|
|MIN(ABS(col)) = 0|col は少なくとも 1 つのゼロを含む|
|MIN(col - 定数) = MAX(col - 定数)|col の最大値と最小値が指定した定数から同じ幅の距離にある|
