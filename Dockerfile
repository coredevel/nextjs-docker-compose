FROM node:current-alpine

WORKDIR /usr/local/src/app

RUN npm install -g update

EXPOSE 3000

COPY ./scripts/run.sh /usr/local/src/scripts/run.sh
RUN chmod +x /usr/local/src/scripts/run.sh

CMD ["sh", "/usr/local/src/scripts/run.sh"]