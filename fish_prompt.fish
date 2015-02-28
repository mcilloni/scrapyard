function fish_prompt -d 'My usual prompt. Really like it. Taken from Gentoo a long time ago'
  set_color --bold green
  echo -n (whoami)" "
  set_color --bold blue
  echo -n (prompt_pwd) "> "
  set_color normal
  printf '%s' (__fish_git_prompt)' '
  set_color normal
end

