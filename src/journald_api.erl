% Copyright 2010-2011, Travelping GmbH <info@travelping.com>

% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the "Software"),
% to deal in the Software without restriction, including without limitation
% the rights to use, copy, modify, merge, publish, distribute, sublicense,
% and/or sell copies of the Software, and to permit persons to whom the
% Software is furnished to do so, subject to the following conditions:

% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.

% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
% FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
% DEALINGS IN THE SOFTWARE.

-module(journald_api).

-define(SYSLOG_ID, "SYSLOG_IDENTIFIER").

%% External API
-export([sendv/1, stream_fd/3, write_fd/2, close_fd/1]).

-on_load(load_nif/0).

-type value() :: number() | atom() | iolist().
-spec sendv([{iolist(),value()}]) -> any().
 
sendv(Args) ->
    sendv_nif(list_conversion(Args, no_syslog)).

sendv_nif(_Args) ->
    "NIF library not loaded".

stream_fd(_A, _B, _C) -> 
    "NIF library not loaded".

write_fd(_Fd, _Msg) ->
    "NIF library not loaded".

close_fd(_Fd) ->
    "NIF library not loaded".

list_conversion([], syslog)    -> [];               % SYSLOG_IDENTIFIER allready set
list_conversion([], no_syslog) ->                   % set SYSLOG_IDENTIFIER 
    [[?SYSLOG_ID, $=, to_list(node())]];
list_conversion([{?SYSLOG_ID,V}|T], _) ->
    [[?SYSLOG_ID, $=, to_list(V)] | list_conversion(T, syslog)];     % SYSLOG_IDENTIFIER was set by user                
list_conversion([{E,V}|T], _)  ->
    [[E, $=, to_list(V)] | list_conversion(T, no_syslog)]; 
list_conversion([_|T], SYSLOG) ->                    % skip bad argument
    list_conversion(T, SYSLOG);
list_conversion(_,_) -> [].                         

to_list(V) when is_integer(V) -> integer_to_list(V);
to_list(V) when is_float(V)   -> float_to_list(V);
to_list(V) when is_atom(V)    -> atom_to_binary(V, utf8);
to_list(V) -> V. 

load_nif() ->
    Dir = "priv",
    PrivDir = case code:priv_dir(ejournald) of      % check existence of priv folder 
        {error, _} -> Dir; 
        X -> X
    end,
    Lib = filename:join(PrivDir, "journald_api"),   % create priv path so journald_api.so 
    erlang:load_nif(Lib, 0).                        % load NIF 
