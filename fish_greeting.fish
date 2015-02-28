function timeofday
  switch (date +%H)
  case 03 04 05
    echo "Can't sleep?"
  case (seq 6 11 | xargs printf "%02d\n")
    echo 'Good morning!'
  case 12 13 14
    echo 'Lunch time!'
  case (seq 15 18)
    echo 'Good afternoon!'
  case (seq 19 22)
    echo 'Good evening!'
  case '*'
    echo 'Good night!'
  end
end

function fish_greeting -d 'Salutes you with date and time'
  printf "%s It's %s.\n" (timeofday) (date +'%A %e, %H:%M')
end
