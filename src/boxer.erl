%% vim: ts=4 sw=4 et
-module(boxer).
-export([
    print/1,
    print/2,
    wrap/1,
    wrap/2,
    add_line_def/2,
    get_line_def/1,
    get_line_char/2
]).

-type line_def_name() :: term().
-type char_key() :: horiz | vert | top_left | top_right | bottom_left | bottom_right | integer(). 

print(Msg) ->
    io:format(wrap(Msg)).

print(Msg, LineDefName) ->
    io:format(wrap(Msg, LineDefName)).

wrap(Msg) ->
    DefaultLineDef = application:get_env(boxer, default_line_def, default),
    wrap(Msg, DefaultLineDef).

wrap(Msg0, LineDefName) ->
    Msg = unicode:characters_to_list(Msg0),
    [H,V,UL,UR,BR,BL] = get_line_def_chars(LineDefName),
    HPadding = get_h_padding(LineDefName),
    VPadding = get_v_padding(LineDefName),
    Pad = lists:duplicate(HPadding, $\s),
    VPad = lists:duplicate(VPadding, $\n),
    MsgLines = string:split(lists:flatten([VPad, Msg, VPad]), "\n", all),
    LongestLine = lists:max([length(X) || X <- MsgLines]) ,
    TotalWidth = LongestLine + (HPadding * 2),
    MsgLines2 = [pad_end(string:chomp(X), LongestLine) || X <- MsgLines],
    lists:flatten([
        make_row(TotalWidth, UL, H, UR),"\n",
        [add_verts([Pad, Line, Pad], V) ++ "\n" || Line <- MsgLines2],
        make_row(TotalWidth, BL, H, BR),"\n"
    ]).
    
get_line_defs() ->
    case persistent_term:get(boxer_line_defs, undefined) of
        undefined ->
            LineDefs = application:get_env(boxer, line_defs, []),
            persistent_term:put(boxer_line_defs, LineDefs),
            LineDefs;
        LineDefs ->
            LineDefs
    end.

put_line_defs(LineDefs) ->
    persistent_term:put(boxer_line_defs, LineDefs).

add_line_def(LineDefName, LookupStr) ->
    LineDefs = get_line_defs(),
    LineDefs2 = lists:keydelete(LineDefName, 1, LineDefs),
    LineDefs3 = [{LineDefName, LookupStr} | LineDefs2],
    put_line_defs(LineDefs3).
    
get_line_def(LineDefName) ->
    LineDefs = get_line_defs(),
    case proplists:get_value(LineDefName, LineDefs, undefined) of
        undefined -> default_chars(LineDefName);
        X -> X
    end.

get_line_def_chars(LineDefName) ->
    Def = get_line_def(LineDefName),
    maps:get(chars, Def, default_chars(default)).

-spec get_line_char(LineDefName :: line_def_name(), Key :: char_key()) -> char().
get_line_char(LineDefName, Key) ->
    Pos = keymap(Key),
    Chars = get_line_def_chars(LineDefName),
    lists:nth(Pos, Chars).

get_h_padding(LineDefName) ->
    Def = get_line_def(LineDefName),
    maps:get(h_padding, Def, 0).

get_v_padding(LineDefName) ->
    Def = get_line_def(LineDefName),
    maps:get(v_padding, Def, 0).
    

keymap(horiz) -> 1;
keymap(vert) -> 2;
keymap(top_left) -> 3;
keymap(top_right) -> 4;
keymap(bottom_left) -> 5;
keymap(bottom_right) -> 6;
keymap(X) when is_integer(X) -> X.

pad_end(Line, ToLength) when length(Line) >= ToLength ->
    Line;
pad_end(Line, ToLength) ->
    ToAdd = ToLength - length(Line),
    Padding = lists:duplicate(ToAdd, $\s),
    Line ++ Padding.

    
%% The total length of this row will be LineWidth+2
make_row(LineWidth, Left, Horiz, Right) ->
    lists:flatten([Left, lists:duplicate(LineWidth, Horiz), Right]).

add_verts(Line, Vert) ->
    lists:flatten([Vert, Line, Vert]).

% chars are in arranged:
% 1 first: straight lines (horiz, then vert), then
% 2) Corners in CSS corner order: upper-left, upper-right, bottom-right, bottom-left.

default_chars(double) ->
    #{h_padding=>0, chars=>"═║╔╗╝╚"};
default_chars(single) ->
    #{h_padding=>0, chars=>"─│┌┐┘└"};
default_chars(hash) ->
    #{v_padding=>1, h_padding=>2, chars=>"######"};
default_chars(_) ->
    default_chars(single).

%replace_tabs_with_spaces(Bin) when is_binary(Bin) ->
%    replace_tabs_with_spaces(unicode:characters_to_list(Bin));
%replace_tabs_with_spaces([$\t|T]) ->
%    "    " ++ replace_tabs_with_spaces(T);
%replace_tabs_with_spaces([H|T]) ->
%    [H|replace_tabs_with_spaces(T)];
%replace_tabs_with_spaces([]) ->
%    [].


