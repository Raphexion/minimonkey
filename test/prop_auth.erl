-module(prop_auth).
-include_lib("proper/include/proper.hrl").
-define(GOD_TOKEN, <<"rNtiPfxtfRBXrb4e9wh8qnTSir83vTeU4WHj7pwq">>).

%%%%%%%%%%%%%%%%%%
%%% Properties %%%
%%%%%%%%%%%%%%%%%%
prop_subscribe_with_wrong_token_test() ->
    ?FORALL({Token, Name, Tag}, {blob(), blob(), blob()},
	    begin
		mm_room_sup:start_link(?GOD_TOKEN),
		{ok, User} = mock_user:start_link(),
		{ok, Room} = mm_room_sup:create_room(Name),
		error =:= mm_room:subscribe(Room, Token, User, Tag)
	    end).

prop_publish_with_wrong_token_test() ->
    ?FORALL({Token, Name, Content}, {blob(), blob(), blob()},
	    begin
		mm_room_sup:start_link(?GOD_TOKEN),
		{ok, Room} = mm_room_sup:create_room(Name),
		error =:= mm_room:publish(Room, Token, Content)
	    end).

prop_subscribe_with_new_token_test() ->
    ?FORALL({Token, Name, Tag}, {blob(), blob(), blob()},
	    begin
		mm_room_sup:start_link(?GOD_TOKEN),
		{ok, User} = mock_user:start_link(),
		{ok, Room} = mm_room_sup:create_room(Name),
		ok = mm_room:permissions(Room, ?GOD_TOKEN, add, to_sub, Token),
		ok =:= mm_room:subscribe(Room, Token, User, Tag) andalso
		    ok =:= mm_room:permissions(Room, ?GOD_TOKEN, revoke, to_sub, Token) andalso
		    error =:= mm_room:subscribe(Room, Token, User, Tag) andalso
		    ok =:= mm_room:unsubscribe(Room, User)
	    end).

prop_publish_with_new_token_test() ->
    ?FORALL({Token, Name, Content}, {blob(), blob(), blob()},
	    begin
		mm_room_sup:start_link(?GOD_TOKEN),
		{ok, Room} = mm_room_sup:create_room(Name),
		ok = mm_room:permissions(Room, ?GOD_TOKEN, add, to_pub, Token),
		ok =:= mm_room:publish(Room, Token, Content) andalso
		    ok =:= mm_room:permissions(Room, ?GOD_TOKEN, revoke, to_pub, Token) andalso
		    error =:= mm_room:publish(Room, Token, Content)
	    end).

%%%%%%%%%%%%%%%
%%% Helpers %%%
%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%
%%% Generators %%%
%%%%%%%%%%%%%%%%%%

blob() ->
    non_empty(binary()).
