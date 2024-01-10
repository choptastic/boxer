all: compile

compile:
	rebar3 compile

shell:
	rebar3 shell

publish:
	rebar3 hex publish
