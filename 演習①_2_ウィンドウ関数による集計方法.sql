/* データ定義DDL-DML */

-- テーブル定義
/*品目マスタ*/
CREATE TABLE m_hinmoku (
      hinmoku_cd CHAR(4) NOT NULL                    -- 品目コード : 固定長文字 4桁
    , hinmoku_name VARCHAR(30)                       -- 品目名称   : 可変長文字列 30桁
    , hanbai_start_date DATE NOT NULL                -- 販売開始日 : 日付
    , hanbai_end_date DATE                           -- 販売終了日 : 日付
    , PRIMARY KEY (hinmoku_cd ,hanbai_start_date)    -- 主キー : 品目コード、販売開始日
);

-- 品目マスタを設定する
INSERT INTO m_hinmoku
VALUES
    -- 品目コード ,品目名称 ,販売開始日 ,販売終了日
      ('A001','イチゴショート','2001/1/1','2999/12/31')
    , ('A002','ガトーショコラ','2001/1/1','2999/12/31')
    , ('A002','前より美味しくなったガトーショコラ','2023/4/1','2999/12/31')
    , ('A002','もっと美味しくなったガトーショコラ','2023/10/1','2999/12/31')
    , ('A002','すごく美味しくなったガトーショコラ','2024/1/1','2999/12/31')
    , ('A003','レアチーズケーキ','2001/1/1','2999/12/31')
    , ('A004','アーモンドクッキー','2001/1/1','2999/12/31')
    , ('A005','チョコビスケット','2001/1/1','2999/12/31')
;

/*日別売上*/
CREATE TABLE t_hibetsu_uriage (
      hanbai_date DATE NOT NULL                      -- 販売日     : 日付
    , hinmoku_cd CHAR(4) NOT NULL                    -- 品目コード : 固定長文字 4桁
    , uriage INTEGER DEFAULT 0                       -- 売上       : 数値 初期値0
    , PRIMARY KEY (hanbai_date ,hinmoku_cd)          -- 主キー     : 販売日、品目コード
);

-- 日別売上を設定する
INSERT INTO t_hibetsu_uriage
VALUES
    -- 販売日 ,品目コード ,売上
      ('2024/3/1','A001',3000)
    , ('2024/3/1','A002',2000)
    , ('2024/3/1','A003',500)
    , ('2024/3/1','A004',1500)
    , ('2024/3/1','A005',10000)
    , ('2024/3/2','A001',2000)
    , ('2024/3/2','A002',0)
    , ('2024/3/2','A003',3000)
    , ('2024/3/2','A004',500)
    , ('2024/3/2','A005',1000)
    , ('2024/3/3','A001',500)
    , ('2024/3/3','A002',1500)
    , ('2024/3/3','A003',1000)
    , ('2024/3/3','A005',3000)
;

/* データ抽出DML */

-- 品目マスタを確認する
WITH mhi AS (
    SELECT
          hinmoku_cd      -- 品目コード
        , hinmoku_name    -- 品目名称
    FROM (
             SELECT
                    hinmoku_cd      -- 品目コード
                  , hinmoku_name    -- 品目名称
                  , ROW_NUMBER()
                        OVER(PARTITION BY hinmoku_cd
                             ORDER BY hanbai_start_date DESC
                        ) AS pri_no  -- 範囲内の順番
             FROM m_hinmoku
    ) mhi_tmp
    WHERE pri_no = 1      -- 範囲内で一番最初のレコード
)

-- 上記全ての集計単位を取得
SELECT 
      thu.hanbai_date      AS "販売日"                 -- 日別売上.販売日
    , thu.hinmoku_cd       AS "品目コード"             -- 日別売上.品目コード
    , mhi.hinmoku_name     AS "品目名称"               -- 品目マスタ.品目名称
    , thu.uriage           AS "売上"                  -- 日別売上.売上
    , SUM(thu.uriage)
          OVER(PARTITION BY thu.hanbai_date) AS "全品目の日別合計"        -- 日別売上を集計（日別）.売上（合計）
    , SUM(thu.uriage)
          OVER(PARTITION BY thu.hinmoku_cd)  AS "品目別で全期間の合計"     -- 日別売上を集計（品目単位）.売上（合計）
    , SUM(thu.uriage) OVER()
                                             AS "全品目・全期間の合計"     -- 日別売上を集計（総合計）.売上（合計）
FROM t_hibetsu_uriage thu                            -- 日別売上

LEFT OUTER JOIN mhi                                  -- 品目マスタ
ON thu.hinmoku_cd = mhi.hinmoku_cd                   -- 品目コードで結合

ORDER BY
      thu.hanbai_date              -- 日別売上.販売日
    , thu.hinmoku_cd               -- 日別売上.品目コード
;
