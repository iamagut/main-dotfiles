if status is-interactive
    # Commands to run in interactive sessions can go here
    fastfetch
    set fish_greeting
end

starship init fish | source

# Added by Antigravity CLI installer
set -gx PATH "/home/iamagut/.local/bin" $PATH
