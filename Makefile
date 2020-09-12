PPROF:=go tool pprof -png -output pprof.png http://localhost:6060/debug/pprof/profile
SLACKCAT:=slackcat --tee --channel isucon10
SLACKRAW:=slackcat --channel isucon10
NGX_LOG:=/var/log/nginx/access.log
MYSQL_LOG:=/tmp/slow-query.log
KATARU_CFG:=./kataribe.toml

before:
	$(eval when := $(shell date "+%s"))
	mkdir -p ~/logs/$(when)
	@if [ -f $(NGX_LOG) ]; then \
		sudo mv -f $(NGX_LOG) ~/logs/$(when)/ ; \
	fi
	# @if [ -f $(MYSQL_LOG) ]; then \
	# 	sudo mv -f $(MYSQL_LOG) ~/logs/$(when)/ ; \
	# fi
	sudo systemctl restart nginx
	# sudo systemctl restart mysql

install-essentials: ## install essentials
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y vim git-core htop dstat unzip graphviz
	# make zsh-init
	# make redis-init
	# make alp-init
	make perconia-init
	# make scripts-dl

ssh_key_add:
	echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAl5qzkPWiUc3vJloG3jB8GOzT2j9m19oJeZmwwvRYgP1Y+aXqcoeOD8b/j+dj0KxXKxw5KnK9E3BapdnyMkQkMnSpob3EZ/4Tuc2QPrNxHtDQGk5Dp52IbRXuu3JvEyoLmeVbLlpurPOCLIZ4kae9YjX/zpTFT4zoaq2Gp+b/uAlq4iUfGq7IF8Hz6qlO62dexLzHgdkq0wSuq4H+eY3pzcceIG8Wo/ts0rHXOqLmOeZBb/Cx8tJ8zQvJBT71ka1mPTUO7fGruvYNcTBWwn86cAJhFtqLYVwr4baMsDf5QyP1B8xexTYpUzhgPT4mmQHRuH62+XMr6f5FDk7Vk0Bt8w== saggggo" >> .ssh/authorized_keys
	echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCs5aDYDHJOT8d5JgpYmHIxydQcS/mPKLSHgk8LpNxoknnCySd5WBS8nCfbSZ7xT2ZdNjkbRhbs34849TyTntgQNXaI5jRR8QTVxl0FANjLu9Lk1fWkv6yWNjrbGzIXH6Zjd6PFxGMuKvBlZAlkTnz9AnZUHH9yGVqNxHB2I23d2B4W+4+uWDmWfTkWGZinsuSMcZeEIycYFJOQ97yXH9p0301W7I40Xhj2KfOCHus4oXrNqUrlBYu3BLcVTk2oBjwci2m2loehFQWoKMqUJ4Hlvx9URD6QIgbq77RL/Euk2Q7UWEaL+Zoo5gfOjKPlIN24uJvDuVjBf4B/VTAxjrdmGhj6nzjzmOACWwstOenMy4ucC5ejSt72seyxKUvVuFERoFWUgvobm1+9S6DEYAaWKolrt8Zvn9kZ9XRJRlV9zuIGzAQ4Ybp129u+VNibWf+DIGghjjl4qruSZ4qU4lXrnMmTdJerNLVFI5TdY8N+lQGzJZbi8q6uE7SkjOVa6q3bFIBbZ8hqt6isOUcBukdPK4VXMzd80lA6yrAvo54qmE7YtCjZeEyxybc72DHspfFLRzsMmIxRRbIxkdowswy2tKab3tNZvZ+sp6VOUXi41S6G9hLPTLHb7p/rXgVHHrXkWTiqGP4UzNttirnhfqvdY/STcUyxx7SJ++oEY4y8vQ== plain@rsa_public" >> .ssh/authorized_keys

zsh-init: ## install zsh
	cd ~/ && sh -c "sudo apt update && sudo apt install -y zsh curl git-core" && rm -rf .oh-my-zsh && git clone https://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh  && sudo rm -f .zshrc && wget https://gist.github.com/plainbanana/5c6495c639674dd08c89bd2de3d881eb/raw/dfa7916f9f1b97cf358f13eaa2f316848d7883ed/.zshrc -P ~/ && if [ -e .bash_profile ]; then cat .bash_profile >> .zprofile; fi;

redis-init: ## install redis-server with systemd daemon
	sudo sh -c "apt install -y build-essential tcl wget && cd /usr/local/src && wget http://download.redis.io/redis-stable.tar.gz && tar xzvf redis-stable.tar.gz && cd redis-stable && make -o3 && make test && make install && sudo mkdir -p /etc/redis && cp redis.conf /etc/redis && wget https://gist.githubusercontent.com/plainbanana/0ec1a4589637c4c2961a834f7a1b7677/raw/95a54628ece623a89d7f8311fff61f83bbbcef2e/redis.service -P /etc/systemd/system/ && sudo adduser --system --group --no-create-home redis && sudo mkdir -p /var/lib/redis && sudo chown redis:redis /var/lib/redis && sudo chmod 770 /var/lib/redis && sudo systemctl enable redis && sudo systemctl start redis"

alp-init: ## install alp
	sudo sh -c "apt update && apt install -y unzip && cd /usr/local/src && wget https://github.com/tkuchiki/alp/releases/download/v0.0.4/alp_linux_amd64.zip && unzip alp_linux_amd64.zip && sudo mv alp_linux_amd64 /usr/local/bin/alp && sudo chown root:root /usr/local/bin/alp"

kataribe-init: ## install kararibe
	sudo sh -c "apt update && apt install -y unzip && cd /usr/local/src && wget  https://github.com/matsuu/kataribe/releases/download/v0.4.1/kataribe-v0.4.1_linux_amd64.zip && unzip kataribe-v0.4.1_linux_amd64.zip && sudo mv kataribe /usr/local/bin/kataribe && sudo chown root:root /usr/local/bin/kataribe"
	/usr/local/bin/kataribe -generate

# h2o-init: ## install H2O web server from source
#	sudo apt update && sudo apt install -y cmake openssl libssl-dev
#	sudo sh -c "cd /usr/local/src && rm -rf ./h20 && git clone https://github.com/h2o/h2o.git && cd h2o && git checkout 7677fce9e41668c6dc21928a19f7d977a186b4c4 && cmake -DWITH_BUNDLED_SSL=on . && make && make install && mkdir -p /etc/h2o && cp examples/h2o/* /etc/h2o && wget https://gist.github.com/plainbanana/5d0f8b22545b17ce5aabdf053050fa67/raw/c51cbe21b52dd8e3ae50ec4dec361dd129a0c3fd/h2o.service -P /etc/systemd/system/ && systemctl enable h2o && systemctl start h2o "

h2o-init: ## install H2O web server from source
	sudo apt update && sudo apt install -y cmake openssl libssl-dev
	sudo sh -c "cd /usr/local/src && rm -rf ./h20 && git clone https://github.com/h2o/h2o.git && cd h2o && git checkout 2a75d26b00fcded91688faadf4313378a1432296 && cmake -DWITH_BUNDLED_SSL=on . && make && make install && mkdir -p /etc/h2o && cp examples/h2o/* /etc/h2o && wget https://gist.github.com/plainbanana/5d0f8b22545b17ce5aabdf053050fa67/raw/c51cbe21b52dd8e3ae50ec4dec361dd129a0c3fd/h2o.service -P /etc/systemd/system/ && systemctl enable h2o && systemctl start h2o "

perconia-init: ## install perconia-toolkit for SQL slowlog
	sudo sh -c "cd /usr/local/src && wget https://www.percona.com/downloads/percona-toolkit/3.2.0/binary/debian/bionic/x86_64/percona-toolkit_3.2.0-1.bionic_amd64.deb && sudo apt update && sudo apt install -y gdebi && sudo gdebi percona-toolkit_3.2.0-1.bionic_amd64.deb"
	sudo sh -c "mkdir -p /var/log/mysql && chown mysql:mysql /var/log/mysql && sudo chmod 700 /var/log/mysql"

scripts-dl: ## download useful scripts
	bash -c "cd ~/ && mkdir -p scripts && cd scripts && wget https://gist.github.com/plainbanana/d1a11ec4cdb64bdc21736e3732dc30d9/raw/cb072f30cfeae71e2bb64ca4f474e225d7c57f37/start-daemon.sh && chmod +x start-daemon.sh"
	bash -c "cd ~/ && cd scripts && wget https://gist.github.com/plainbanana/5947ef8da734bc1302a0820fb97e0396/raw/2fa0d3bd8b8a5dfbdbe3445b6848799f3e77c83b/refresh.sh && chmod +x refresh.sh"

node-init:
	sudo apt-get install -y nodejs npm
	sudo npm cache clean
	sudo npm install n -g
	sudo n stable
	sudo ln -sf /usr/local/bin/node /usr/bin/node
	sudo apt-get purge -y nodejs npm
	echo "systemdの設定ファイルからnodeパスを書き換え"

golang-1.9: ## install gokang-1.9
	sudo apt update && sudo apt install -y software-properties-common
	echo "export GOPATH=$HOME/.go" >> .bashrc
	echo "export GOPATH=$HOME/.go" >> .zshrc        
	echo "export GOBIN=$GOPATH/bin" >> .bashrc        
	echo "export GOBIN=$GOPATH/bin" >> .zshrc        
	export GOPATH=$HOME/.go        
	export GOBIN=$GOPATH/bin        
	sudo add-apt-repository ppa:hnakamur/golang-1.9        
	sudo apt update        
	sudo apt install -y golang-go

pprof:
	$(PPROF)
	$(SLACKRAW) -n pprof.png ./pprof.png

slackcat-init:
	wget https://github.com/bcicen/slackcat/releases/download/v1.5/slackcat-1.5-linux-amd64 -O slackcat
	sudo mv slackcat /usr/local/bin/
	sudo chmod +x /usr/local/bin/slackcat
	slackcat --configure

kataribe:
	sudo cat $(NGX_LOG) | kataribe -f ./kataribe.toml | $(SLACKCAT)
