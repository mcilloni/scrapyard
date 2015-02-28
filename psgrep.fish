function psgrep -d 'Gets full details about processes with a given name'
  set argc (count $argv)
  if test $argc -ne 1 
    echo "$_: wrong number of arguments ($argc)" >&2
  else
    pgrep "$argv" | xargs ps fp ^&-
  end
end

