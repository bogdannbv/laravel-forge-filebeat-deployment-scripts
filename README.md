# An extremely specific repository

## Usage

Download the repository and extract it.
```shell
mkdir ./filebeat-deployment \
 && curl -L https://github.com/bogdannbv/laravel-forge-filebeat-deployment-scripts/archive/refs/heads/main.tar.gz | tar -xz -C ./filebeat-deployment --strip-components=1 \
 && cd ./filebeat-deployment
```

Run the `install.sh` script
```shell
./install.sh -i "cloud-id" -a "cloud-auth" -n "app-name" -p "/path/to/app/logs/filebeat-*.log"
```

