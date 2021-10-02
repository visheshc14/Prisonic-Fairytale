ERL_INCLUDE_PATH=$(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)

all: priv/my_nif.so

priv/my_nif.so: my_nif.c
	gcc -fPIC -I$(ERL_INCLUDE_PATH) -dynamiclib -undefined dynamic_lookup -o priv/my_nif.so my_nif.c
