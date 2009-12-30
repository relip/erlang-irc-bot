An extendable ircbot written in Erlang
======================================

It all started when I decided I need to learn Erlang. At the same time I needed
a simple ircbot to handle some of the channels I frequent on. These two things
put together and I decided to start this project.

The evolution of my knowledge can be best seen from the history of the [git
commits][commits].

[commits]: http://github.com/gdamjan/erlang-irc-bot/commits/master

Now that the bot is extendable by plugins, and quite stable it's becoming prety
usefull. It still needs improvements and is work in progress, but plugins can
be written for anything.


Patches, help and feature requests can be sent on the github issue tracker.
There's a TODO list I keep there too.


The bot is MIT licensed (for no particular reason), it's a very liberal license
with no strings, so you can really do whatever you want with it.


Quick start
-----------

First, compile everything:

    make

Edit and rename the settings.cfg.sample file (to settings.cfg), then start 
an Erlang REPL shell. Make sure the module path is set to the ./ebin/
directory, where all the compiled .beam files are:

    make run-shell

or

    erl -pa ./ebin

Once in the Erlang REPL you can start the bot with:
    
    {ok, Settings} = file:consult("settings.cfg").
    {ok, IrcBot} = ircbot_server:start_link(Settings).
    gen_server:call(IrcBot, connect).
    gen_server:call(IrcBot, {add_plugin, 'plugins.rps', []}).

You can make changes to the source code & plugins while the bot is running. 
Just hit "make" in another terminal and then, if everything is ok, in the erlang REPL run:

    l('plugins.rps').

or

    l(ircbot_server).

Erlangs [code switching][code switching] and the gen_server/gen_event frameworks 
will handle all the details to run the new code without even disconnecting.

[code switching]: http://en.wikipedia.org/wiki/Erlang_%28programming_language%29#Hot_code_loading_and_modules
