FROM xovox/crystal-with-git:0.0.2

WORKDIR /usr/local
ADD . /app
WORKDIR /app 

# RUN apt-get update && apt-get install -y git

# RUN shards install 

RUN crystal build --release src/simple-auth.cr

EXPOSE 3000

CMD ./simple-auth