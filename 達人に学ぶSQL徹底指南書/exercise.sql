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
