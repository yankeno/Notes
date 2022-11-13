-- 演習問題1 -> 断念...
SELECT
    CASE
        sex
        WHEN 1 THEN '男'
        ELSE '女' AS '性別',
        sum(population) AS '全国',
        CASE
            FROM
                PropTbl2
            GROUP BY
                sex;

-- 演習問題3-①
SELECT
    p1.name AS name_1,
    p2.name AS name_2
FROM
    Products p1
    INNER JOIN Products p2 ON p1.name >= p2.name
ORDER BY
    p1.name;

-- 演習問題5-①
SELECT
    DISTINCT `key`
FROM
    ArrayTbl t1
WHERE
    EXISTS(
        SELECT
            `key`
        FROM
            ArrayTbl t2
        WHERE
            t1.`key` = t2.`key`
        GROUP BY
            `key`
        HAVING
            SUM(
                CASE
                    COALESCE(val, 0)
                    WHEN 1 THEN 1
                    ELSE 0
                END
            ) = COUNT(*)
    );

-- 演習問題5-① 模範解答
SELECT
    DISTINCT `key`
FROM
    ArrayTbl t1
WHERE
    NOT EXISTS(
        SELECT
            *
        FROM
            ArrayTbl t2
        WHERE
            t1.`key` = t2.`key`
            AND (
                t2.val <> 1
                OR t2.val IS NULL
            )
    );

-- 演習問題6-①
SELECT
    CASE
        WHEN COUNT(*) <> MAX(seq) THEN '歯抜けあり'
        ELSE '歯抜けなし'
    END
FROM
    SeqTbl;

-- 演習問題6-②
SELECT
    dpt
FROM
    Students
GROUP BY
    dpt
HAVING
    count(*) = sum(
        CASE
            WHEN sbmt_date BETWEEN '2018-09-01'
            AND '2018-09-30' THEN 1
            ELSE 0
        END
    );

-- 演習問題6-③ -> 断念...
SELECT
    shop,
    COUNT(i.item) AS my_item_cnt,
    CASE
        WHEN COUNT(si.item) > COUNT(i.item) THEN COUNT(si.item) - COUNT(i.item)
        ELSE 0
    END AS diff_cnt
FROM
    ShopItems si
    LEFT JOIN Items i ON si.item = i.item
GROUP BY
    shop;

-- 演習問題6-③ 模範解答
SELECT
    si.shop,
    count(si.item) AS my_item_cnt count(
        SELECT
            count(item) form items
    ) - count(si.item) AS diff_cnt
FROM
    ShopItems si
    INNER JOIN Items i ON si.item = i.item
GROUP BY
    si.shop;

-- 演習問題8-②
SELECT
    employee,
    COUNT(emp.child)
FROM
    (
        SELECT
            employee,
            child_1 AS child
        FROM
            Personnel
        UNION
        ALL
        SELECT
            employee,
            child_2 AS child
        FROM
            Personnel
        UNION
        ALL
        SELECT
            employee,
            child_3 AS child
        FROM
            Personnel
    ) emp
GROUP BY
    employee
ORDER BY
    COUNT(emp.child) DESC;

SELECT
    project_id
FROM
    Projects
GROUP BY
    project_id
HAVING
    COUNT(*) = SUM(
        CASE
            WHEN step_nbr <= 1
            AND STATUS = '完了' THEN 1
            WHEN step_nbr > 1
            AND STATUS = '待機' THEN 1
            ELSE 0
        END
    );
