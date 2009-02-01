%%%-------------------------------------------------------------------
%%% File:      fnv.erl
%%% @author    Cliff Moon <> []
%%% @copyright 2009 Cliff Moon
%%% @doc  
%%%
%%% @end  
%%%
%%% @since 2009-01-29 by Cliff Moon
%%%-------------------------------------------------------------------
-module(fnv).
-author('cliff@powerset.com').

-define(SEED, 2166136261).
%% API
-export([start/0, stop/1, hash/1, hash/2]).

%%====================================================================
%% API
%%====================================================================
%%--------------------------------------------------------------------
%% @spec 
%% @doc
%% @end 
%%--------------------------------------------------------------------
start() ->
  case load_driver() of
    ok -> open();
    {error, Err} ->
      Msg = erl_ddll:format_error(Err),
      {error, Msg}
  end.

stop(P) ->
  unlink(P),
  exit(P, die).
  
hash(Thing) ->
  hash(Thing, ?SEED).
  
% hash(Thing, Seed) when is_list(Thing) -> %assume io_list
%   P = get_or_open(),
%   port_command(P, [term_to_binary(Seed)] ++ Thing),
%   recv(P);
  
hash(Thing, Seed) when is_binary(Thing) ->
  P = get_or_open(),
  port_command(P, [term_to_binary(Seed), Thing]),
  recv(P);
  
hash(Thing, Seed) ->
  P = get_or_open(),
  port_command(P, [term_to_binary(Seed), term_to_binary(Thing)]),
  recv(P).

%%====================================================================
%% Internal functions
%%====================================================================
get_or_open() ->
  case get(fnv) of
    undefined -> start();
    P -> P
  end.

open() ->
  P = open_port({spawn, fnv_drv}, [binary]),
  put(fnv, P),
  P.

load_driver() ->
  Dir = filename:join([filename:dirname(code:which(?MODULE)), "..", "lib"]),
  erl_ddll:load(Dir, "fnv_drv").

recv(P) ->
  receive
    {P, {data, Bin}} -> binary_to_term(Bin)
  end.
  
