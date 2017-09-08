echo 'Main.elm' | entr -s 'elm-make Main.elm --output deploy/main.js && xdotool search --onlyvisible --class Firefox windowfocus key F5 && xdotool search --onlyvisible --class Howl windowfocus'
