function touch_and_open --argument-names filename --description "Touch and open file in VS Code"
    touch "$filename" && code "$filename"
end
