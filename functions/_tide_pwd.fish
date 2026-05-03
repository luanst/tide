set_color -o $tide_pwd_color_anchors | read -l color_anchors
set_color $tide_pwd_color_truncated_dirs | read -l color_truncated
set -l reset_to_color_dirs (set_color normal -b $tide_pwd_bg_color; set_color $tide_pwd_color_dirs)

set -l unwritable_icon $tide_pwd_icon_unwritable' '
set -l home_icon $tide_pwd_icon_home' '
set -l pwd_icon $tide_pwd_icon' '

eval "function _tide_pwd
    set -l path (shorten_path \$PWD)
    set -l icon \"$pwd_icon\"
    if set -l home_matches (string match -e -r \"^~.*\" \"\$path\")
        set -f icon \"$home_icon\"
    end
    test -w . || set -f icon \"$unwritable_icon\"
    set -l split_path (string split / \$path)
    set split_path[-1] \"$color_anchors\$split_path[-1]$reset_to_color_dirs\"
    if test (count \$split_path) -gt 1; and set -l mapping_matches (string match -e -r \"^@.*\" \"\$split_path[1]\")
	set split_path[1] \"$color_truncated\$split_path[1]$reset_to_color_dirs\"
    end
    string join / -- \$split_path | read -l path
    set -l displayed_pwd \"$reset_to_color_dirs\$icon\$path$reset_to_color_dirs\"
    string length -V \"\$displayed_pwd\" | read -g _tide_pwd_len
    echo \$displayed_pwd
end"

eval "function _tide_pwd_old
    if set -l split_pwd (string replace -r '^$HOME' '~' -- \$PWD | string split /)
        test -w . && set -f split_output \"$pwd_icon\$split_pwd[1]\" \$split_pwd[2..] ||
            set -f split_output \"$unwritable_icon\$split_pwd[1]\" \$split_pwd[2..]
        set split_output[-1] \"$color_anchors\$split_output[-1]$reset_to_color_dirs\"
    else
        set -f split_output \"$home_icon$color_anchors~\"
    end

    string join / -- \$split_output | string length -V | read -g _tide_pwd_len

    i=1 for dir_section in \$split_pwd[2..-2]
        string join -- / \$split_pwd[..\$i] | string replace '~' $HOME | read -l parent_dir # Uses i before increment

        math \$i+1 | read i

        if path is \$parent_dir/\$dir_section/\$tide_pwd_markers
            set split_output[\$i] \"$color_anchors\$dir_section$reset_to_color_dirs\"
        else if test \$_tide_pwd_len -gt \$dist_btwn_sides
            string match -qr \"(?<trunc>\..|.)\" \$dir_section

            set -l glob \$parent_dir/\$trunc*/
            set -e glob[(contains -i \$parent_dir/\$dir_section/ \$glob)] # This is faster than inverse string match

            while string match -qr \"^\$parent_dir/\$(string escape --style=regex \$trunc)\" \$glob &&
                    string match -qr \"(?<trunc>\$(string escape --style=regex \$trunc).)\" \$dir_section
            end
            test -n \"\$trunc\" && set split_output[\$i] \"$color_truncated\$trunc$reset_to_color_dirs\" &&
                string join / \$split_output | string length -V | read _tide_pwd_len
        end
    end

    string join -- / \"$reset_to_color_dirs\$split_output[1]\" \$split_output[2..]
end"
