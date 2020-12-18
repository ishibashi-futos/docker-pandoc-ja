# pandoc japanese docker

日本語対応版Pandocを使えるDocekrをビルドするためのリポジトリです.

## Build.

```bash
docker build -t docker-pandoc-ja:latest
```

## Usage Sample

* コンテナを起動する
  * `docker run -it --rm -v $(pwd):/workspace docker-pandoc-ja:latest`
* コマンドを実行する
  * pandoc ./README.md --from=markdown --to=docx --output=README.docx
