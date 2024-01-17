# el-mobile-app-host
EL Mobile AppHost

![MacDown logo](public/favicon.ico)

## Introduce (介绍)
This repo is upgrade from ruby 2.5.1, rails 5 to ruby 3.2.2 and rails 7 based on https://bitbucket.eflabs.cn/projects/MOBILE/repos/app-host/browse, the original repo is forked from https://github.com/pluosi/app-host

A lightweight app package host server for iOS and Android. Like fir.im, can deploy in intranet of your company. It's open source and very easily for you to develop on your own requirements.

一个轻量级的包托管网站，app-host 主要用于 iOS 和 Android 的包管理，作用类似于fir.im，不同之处是可以自由部署在内网，方便了公司项目保密。并且代码开源也可以方便根据各自需求进行定制化开发。

## Features 目前的功能
1.New App 新建包<br>
2.New Plat 包底下新建渠道（ iOS，安卓，各种环境都归为渠道，例如 iOS 生产，iOS 沙盒，iOS 越狱版，Android 生产等）<br>
3.Upload ipa/apk/aab on plat page 渠道下面上传包<br>
4.Upload ipa/apk/aab by api 
4.account and permission management 帐号和权限管理<br>
6.analyze ipa/apk infos 解析包信息，包括 iOS 的包类型 ADHOC 还是 release，udid，安卓的签名证书等<br>

## build docker image by your own
```
1. > git clone https://github.com/efcloud/el-mobile-app-host.git
2. > cd el-mobile-app-host
5. > ./docker/launcher bootstrap -v #depends on network status, if you are in bad network, just retry it.
6. > ./docker/launcher start
7. visit http://localhost:8686 , you can change `local_port` in docker/launcher
ps:db and upload files will be all in shared directory
```

## develop at local
0. > brew install rbenv
1. > rbenv install 3.2.2
2. write init script to your .bashrc or .zshrc
```sh
# setting rbenv
if command -v rbenv 1>/dev/null 2>&1; then
  eval "$(rbenv init -)"
  eval "$(rbenv global 3.2.2)"
fi
```
3. source config files
>source ~/.bashrc
or
>source ~/.zshrc
4. > rbenv rehash
5. > gem install bundler
6. > git clone https://github.com/efcloud/el-mobile-app-host.git
7. > cd app-host
8. > bundle install
10. > rbenv rehash
// refresh cache of rbenv，otherwise the terminal can't find rails
11. > RAILS_ENV=development rake db:migrate
// generate db
10. > rails s
// run dev mode
11. visit http://localhost:3000
```

2. nginx config for proxy_pass app_host container
```sh
upstream apphost {
    # if your nginx is running on docker, use el-mobile-app-host's container name instead of `localhost`
    server localhost:8686;
}

server {
    listen      80;
    server_name apphost.example.com;
    return 301 https://$http_host$request_uri;
}

server {
    server_name apphost.example.com;

    client_max_body_size 1000M;

    location / {
       proxy_redirect off;
       proxy_set_header Host $http_host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto $scheme;
       proxy_pass http://apphost;
    }

    # the ssl config is managed by Certbot, please change the ssl related path based on your server config.
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/apphost.example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/apphost.example.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}
```

3. How to upload your app with api
visit http://localhost:3000/users/1/api_token to see the Usage
```bash
# with only required params
# - plat_id: is the target platform id of your app, you can find it in url http://localhost:3000/apps/1/plats/1
# - token: copy from ApiToken page which you can visit through the user's menu on the top right corner
# - file: need start with `@` for local file path with curl command
curl --form plat_id=1 --form token=b2085391f7c0dbf485f45b381a2a21a5f7a41768 --form file=@/Downloads/Smart_English_Mobile.ipa http://localhost:3000/api/pkgs
```

## known issues
1. if the logo of apk is not an image，can't show logo，cause we haven't analyze logo in xml
2. user can delete upload files
3. can't analyze aab package

## License
AppHost is released under the MIT license. See LICENSE for details.



 
