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

/* データ抽出DML */

-- 品目マスタを確認する
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
;
