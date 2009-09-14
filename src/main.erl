-module(main).
-author('gdamjan@gmail.com').

-export([start/1, client/4, codeswitch/1]).

-define(REALNAME, "Damjan's experimental Erlang IRC bot").
-define(CRNL, "\r\n").

start(Args) ->
    spawn(?MODULE, client, Args).

client(SomeHostInNet, Port, Nick, Channels) ->
    % open a TCP connectin to the IRC server, we set the socket options to
    % {packet, line} which means will receive data line-by-line (which is very
    % neat for the IRC protocol).
    % FIXME: error handling
    {ok, Sock} = gen_tcp:connect(SomeHostInNet, Port,
                    [binary, {active, true}, {packet, line}]),
    registerNick(Sock, Nick),
    joinChannels(Sock, Channels),
    main_loop(Sock).


registerNick(Sock, Nick) ->
    % Connection Registration:
    % on freenode you must fire these very soon after connecting or the server
    % disconnects you
    gen_tcp:send(Sock, ["NICK ", Nick, ?CRNL]), 
    gen_tcp:send(Sock, ["USER ", Nick, " 0 *  : ", ?REALNAME, ?CRNL]).

% recurses through the list 'Channels' and JOINs each of them
% no error checking!
joinChannels(Sock, Channels) ->
    [ Channel| Rest ] = Channels,
    joinChannels(Sock, Channel, Rest).

joinChannels(Sock, Channel, []) ->
    gen_tcp:send(Sock, ["JOIN ", Channel, ?CRNL]);

joinChannels(Sock, Channel, Channels) ->
    joinChannels(Sock, Channel, []),
    [ Channel_| Rest ] = Channels,
    joinChannels(Sock, Channel_, Rest).


% this is the main loop of the process, it will receive data from the socket
% and also messages from other processes, will loop forever until an unknown
% message is received.
main_loop(Sock) ->
    receive
        % When the process receives this message, it will call 'codeswitch/1' 
        % from the *latest* MODULE version, 
        % codeswitch/1 just calls main_loop/1 again
        code_switch ->
            ?MODULE:codeswitch(Sock);
        % message received from another process
        {Client, send_data, Binary} ->
            case gen_tcp:send(Sock, [Binary]) of
                ok ->
                    Client ! {self(), data_sent},
                    main_loop(Sock)
            end;
        % data received from the socket
        {tcp, Sock, Line} ->
            case process(Line) of
                ok ->
                    ok;
                Answer ->
                    gen_tcp:send(Sock, Answer)
            end,
            main_loop(Sock);
        % FIXME: handle errors on the socket 
        {tcp_closed, Sock} ->
            io:format("Socket ~w closed [~w]~n", [Sock, self()]),
            ok;
        % anything else the loop will exit
        Other ->
            io:format("Got ~w - goodbye!~n", [Other]),
            gen_tcp:send(Sock, ["QUIT : erlang sucks - just kidding :)", ?CRNL]),
            gen_tcp:close(Sock),
            ok
    end.

process(Line) ->
    case Line of
        <<"PING", Rest/binary>> ->
            [<<"PONG">>, Rest];
        Else ->
            io:format("~ts", [Else]),
            ok
    end.

% when this function is called Erlang will have the chance to run a new
% main_loop(Sock) implementation (see: Hot code reloading)
codeswitch(Sock) -> 
   main_loop(Sock).