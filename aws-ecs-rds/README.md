# 構成図

![fargate-aurora](https://user-images.githubusercontent.com/62602802/180592817-0cc2598f-5cc8-41c7-9e75-c44220e8ea2a.svg)

# ディレクトリ構成

下記リンク参考にして構成している

[Terraform の構成 - tech.guitarrapc.cóm](https://tech.guitarrapc.com/entry/2021/05/17/012156#%E3%82%88%E3%81%8F%E4%BD%BF%E3%81%A3%E3%81%A6%E3%81%84%E3%82%8B%E6%A7%8B%E6%88%90)

```
├── scripts
│   ├── ecs-exec.sh
｜   ├── run-bastion.sh
｜   └── stop-bastion.sh
├── terraform
│   ├── dev
│   │    ├──locals.tf
｜   ｜    ├──main.tf
│   └── modules
```

```
module の最小構成
.
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
```

# 要点

- cloudfront -> s3 による静的サイトホスティング
- alb -> ecs -> rds による API サーバーとデータ永続化部分の構築
- bastion-fargate は必要なタイミングで適宜起動・停止・接続が必要（専用のスクリプト有り）
- cloudwatch に配信される app,rds,waf ログ等は firehose -> s3 で保存
