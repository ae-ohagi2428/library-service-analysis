-- Ⅰ 「日本の図書館 統計と名簿 2019年版」の取得・内容確認
-- １．データ確認１：1自治体1行かどうかの確認
-- ① 行数を確認
SELECT COUNT(*)
FROM library_stats_2019;
-- 【確認結果】1343件

-- ② 自治体数を確認
SELECT COUNT(DISTINCT 設置者コード)
FROM library_stats_2019;
-- 【確認結果】1343件
-- 1自治体1行となっている

-- ２．データ確認２：奉仕人口にnull・0がないかどうか
-- ① NULL値の確認
SELECT COUNT(*)
FROM library_stats_2019
WHERE 奉仕人口 IS NULL;
-- 【確認結果】0件

-- ② 0の確認
SELECT COUNT(*)
FROM library_stats_2019
WHERE 奉仕人口 = 0;
-- 【確認結果】0件
-- 奉仕人口にnullや0はない

-- ３．データ確認３：外れ値の確認
-- ① 最小値・最大値・平均値の確認
SELECT MIN(奉仕人口), MAX(奉仕人口), AVG(奉仕人口)
FROM library_stats_2019;
-- 【確認結果】
-- MIN(奉仕人口)：166
-- MAX(奉仕人口)：3737845
-- AVG(奉仕人口)：92888.5852568876

-- ② 最小値が少ないため、該当行を確認
SELECT *
FROM library_stats_2019
WHERE 奉仕人口 = 166;
-- 【確認結果】
-- 青ケ島村 奉仕人口：166

-- ③ 奉仕人口の値が小さい市区町村を5位まで確認
SELECT 県名, 市区町村名, 奉仕人口
FROM library_stats_2019
ORDER BY 奉仕人口 ASC LIMIT 5;
-- 【確認結果】
-- 1. 東京	青ケ島村   166
-- 2. 長野	根羽村     952
-- 3. 長野	南相木村  1038
-- 4. 沖縄	多良間村  1169
-- 5. 群馬	上野村    1223

-- ④ あわせて最大値の該当行を確認
SELECT *
FROM library_stats_2019
WHERE 奉仕人口 = 3737845;
-- 【確認結果】
-- 横浜市 奉仕人口：3737845

-- ⑤ 奉仕人口の値が大きい市区町村を5位まで確認
SELECT 県名, 市区町村名, 奉仕人口
FROM library_stats_2019
ORDER BY 奉仕人口 DESC LIMIT 5;
-- 【確認結果】
-- 1. 神奈川  横浜市    3737845
-- 2. 大阪    大阪市    2702432
-- 3. 愛知    名古屋市  2288240
-- 4. 北海道  札幌市    1952348
-- 5. 兵庫    神戸市    1542935

-- ４．奉仕人口を区切り分析することを検討
-- 奉仕人口5万人以上の自治体数
SELECT COUNT(*)
FROM library_stats_2019
WHERE 奉仕人口 >= 50000;
-- 【確認結果】544件
-- サンプル数として適切と判断


-- Ⅱ 「全市町村の主要財政指標（令和元年度）」を取得・内容確認
-- １．データ確認１：1自治体1行かどうかの確認
-- ① 行数を確認
SELECT COUNT(*)
FROM fiscal_index_2019;
-- 【確認結果】1742件

-- ② 自治体数を確認
SELECT COUNT(DISTINCT 団体コード)
FROM fiscal_index_2019;
-- 【確認結果】1742件
-- 1自治体1行となっている

-- ２．データ確認２：財政力指数にNULL・0がないかどうか
-- ① NULL値の確認
SELECT 団体名, 財政力指数
FROM fiscal_index_2019
WHERE 財政力指数 IS NULL;
-- 【確認結果】0件

-- ② 0の確認
SELECT 団体名, 財政力指数
FROM fiscal_index_2019
WHERE 財政力指数 = 0;
-- 【確認結果】0件

-- Ⅲ JOIN～ビューの作成
-- １．２つのテーブルをJOINできるか検証
SELECT L.設置者コード, L.県コード, L.県名, L.市区町村名, L.奉仕人口, 
       L.蔵書冊数, L.受入冊数, L.うち購入, L.登録者数, L.貸出数, 
       L.予約件数, L.決算額図書館費, L.決算額資料費, F.財政力指数
FROM library_stats_2019 AS L
LEFT JOIN fiscal_index_2019 AS F
ON printf('%05d', L.設置者コード) = SUBSTR(printf('%06d', F.団体コード), 1, 5)
WHERE F.財政力指数 IS NULL;
-- 【確認結果】0件
-- 結合キーにより正しくLEFT JOINできたことを確認

-- ２．ビューの作成
CREATE VIEW v_library_over50k AS
SELECT L.設置者コード, L.県コード, L.県名, L.市区町村名, L.奉仕人口, 
       L.蔵書冊数, L.受入冊数, L.うち購入, L.登録者数, L.貸出数, 
       L.予約件数, L.決算額図書館費, L.決算額資料費, F.財政力指数
FROM library_stats_2019 AS L
LEFT JOIN fiscal_index_2019 AS F
  ON printf('%05d', L.設置者コード) = SUBSTR(printf('%06d', F.団体コード), 1, 5)
WHERE L.奉仕人口 >= 50000;

-- ３．ビューの確認
SELECT COUNT(*)
FROM v_library_over50k;
-- 【確認結果】544件

-- 以降は複数行の欠損値確認等を含むため、analysis.ipynbにて処理。


