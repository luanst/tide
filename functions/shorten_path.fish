function shorten_path -a path
    # Mappings
    set -l shortcut_file "$HOME/.config/fish/tide-shortcuts.json"
    set -l shortcuts (cat $shortcut_file | jq -r 'sort_by(.value | -length) | .[] | .name, .value')
    
    # Replace each mapping in the path
    for i in (seq 1 2 (count $shortcuts))
        set -l shorthand $shortcuts[$i]
        set -l full_path $shortcuts[(math $i + 1)]
        abbr -a "$shorthand" "$full_path"
        set path (string replace -r -a "^$full_path" "$shorthand" $path)
    end

    # Replace home folder name with ~
    set path (string replace -r -a "^$HOME" "~" $path)

    echo $path
end

