function _tide_sub_shortcut
    set -l shortcut_file "$HOME/.config/fish/tide-shortcuts.json"
    test -e $shortcut_file || echo "[]" > $shortcut_file
    set -l shortcuts (cat $shortcut_file | jq -r '.[] | .name, .value')
    switch $argv[1]
        case list
            echo "Tide shortcuts:"
            for i in (seq 1 2 (count $shortcuts))
		set -l j (math $i + 1)
		set -l name $shortcuts[$i]
		set -l value $shortcuts[$j]
                echo "$name = $value"
            end
        case add
            set -l found 0
            for i in (seq 1 2 (count $shortcuts))
		set -l j (math $i + 1)
                if test $shortcuts[$i] = $argv[2]
                    set found 1
		    set shortcuts[$j] $argv[3]
		    break
                end
            end
	    if test $found -lt 1
                set -a shortcuts $argv[2]
                set -a shortcuts $argv[3]
            end
            echo "Added Tide shortcut $argv[2] = $argv[3]" 
        case remove
	    set -l new_shortcuts
            for i in (seq 1 2 (count $shortcuts))
		if test $shortcuts[$i] != $argv[2]
		    set -a new_shortcuts $shortcuts[$i]
		    set -a new_shortcuts $shortcuts[(math $i + 1)]
		end
	    end
	    set shortcuts $new_shortcuts
	    echo "Removed Tide shortcut $argv[2]"
        case rename
            for i in (seq 1 2 (count $shortcuts))
		if test $shortcuts[$i] = $argv[2]
		    set shortcuts[$i] $argv[3]
		end
	    end
	    echo "Renamed Tide shortcut $argv[2] to $argv[3]"
        case '*'
            echo "Unknown subcommand $argv[1]"
            return 1
    end
    set -l json
    for i in (seq 1 2 (count $shortcuts))
	set -l j (math $i + 1)
	set -l name (string escape $shortcuts[$i])
	set -l value (string escape $shortcuts[$j])
        set -a json "{name: \"$name\", value: \"$value\"}"
    end
    set -l json (string join ',' -- $json)
    set -l json "[$json]"
    jq -n $json > $shortcut_file
end
