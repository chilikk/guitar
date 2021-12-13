from erlang:24-alpine as builder

run apk add --no-cache curl make git

run mkdir /erlang.mk && cd /erlang.mk && curl -O https://erlang.mk/erlang.mk

copy . /guitar

workdir /guitar

run cp /erlang.mk/erlang.mk .

run make deps

run make rel

####################
from erlang:24-alpine

env DB_DIR=/db

volume /db

copy --from=builder /guitar/_rel/guitar /guitar

cmd /guitar/bin/guitar foreground
