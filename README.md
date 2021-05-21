# ECS(Aws) + Terraform でWebサービスを構築する

2つのaz上にそれぞれ public subnet を作成  
そこにALB、RDS、ECS（frontend、backendそれぞれ）を作成  

※ ECS、RDSは private subnet におくのが良いが、NATの料金が高いからpublicで検証  

※ public subnet においても、以下のSGの設定で本番でも大丈夫な気がする  

SG  
・ALB（in: 80のみ許可、out: 全許可）  
・ECS（in: vpc内かつ80のみ許可、out: 全許可）  
・RDS（in: vpc内かつ3306のみ許可、out: 全許可）  

ざっくり、Route53 → ALB → ECS → コンテナ という処理フロー  

### setup
1. aws cliを使えるようにしておく
2. awsコンソールよりs3にtfstate保存用のバケットを作成(例: ecs-terraform-example-tfstate)  
3. main.tfのs3バケット名を1.で決めたものに変更  
4. variables.tf.exampleをvariables.tfにリネームして内容を書き換える
5. ターミナル操作  
```
$ terraform init
$ terraform apply
```

・検証環境  
Terraform v0.13.6  
Aws CLI 2.2.3

### アプリのアップデート(backendの場合)
```
# ECRにログイン(x:AWSアカウントID)
$ aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin x.dkr.ecr.ap-northeast-1.amazonaws.com

# アプリのイメージ作成(x:AWSアカウントID、y:Dockerイメージのタグ名)
$ cd backend
$ docker build -t ecs-example-backend .
$ docker tag ecs-example:latest x.dkr.ecr.ap-northeast-1.amazonaws.com/ecs-example-backend:y

# ECRへPUSH(x:AWSアカウントID、y:Dockerイメージのタグ名)
$ docker push x.dkr.ecr.ap-northeast-1.amazonaws.com/ecs-example-backend:y

# PUSHしたDockerイメージでデプロイ
$ variables.tf の ecr_backend_nameのタグ名を変更
$ terraform apply
```

### 環境変数
.variables.tf.sampleをvariables.tfにリネームして使用する  
.gitignoreの対象としているのでパスワードなど公開したくない情報をここに記述する  

### ログ
各コンテナのログの出力先はCloudWatch

### やってないこと
・よりよいデプロイの仕組化（code pipelineを使うの主流ぽい）  
・バッチ or cron（やり方がいくつかありそう）  
・CloudWatch以外のログ出力  
・https  
・<b>開発、本番環境を考慮した運用方法と事故防止と対策</b>  
