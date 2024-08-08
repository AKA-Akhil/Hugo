
cd "$(dirname "$0")"

docker build -t my-hugo-site .

docker stop my-hugo-site 2>/dev/null
docker rm my-hugo-site 2>/dev/null
ls

docker run -p 1313:1313 my-hugo-site
